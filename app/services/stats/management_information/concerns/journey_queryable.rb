# frozen_string_literal: true

require_relative 'claim_type_filterable'

module Stats
  module ManagementInformation
    module JourneyQueryable
      extend ActiveSupport::Concern

      included do
        def prepare
          ActiveRecord::Base.connection.execute(drop_journeys_func)
          ActiveRecord::Base.connection.execute(create_journeys_func)
        end

        def drop_journeys_func
          <<~SQL
            DROP FUNCTION IF EXISTS journeys(integer);
          SQL
        end

        def create_journeys_func
          <<~SQL
            CREATE OR REPLACE FUNCTION journeys(in_claim_id int)
            RETURNS TABLE(journey jsonb)
            COST 100
            STABLE
            AS
            $BODY$
            DECLARE
              rec record;
              transition jsonb;
              slice jsonb := '[]'::jsonb;
              filtered_states constant varchar[] := array['draft', 'archived_pending_delete' , 'archived_pending_review'];
              completed_states constant varchar[] := array['rejected', 'refused', 'authorised', 'part_authorised'];
            BEGIN
              for rec in (
                with transitions as (
                  select t.claim_id,
                         t.to,
                         t.created_at,
                         t.reason_code,
                         t.reason_text,
                         (authors.first_name || ' ' || authors.last_name) as author_name,
                         (subjects.first_name || ' ' || subjects.last_name) as subject_name
                  from claim_state_transitions t
                  left outer join users as authors
                    on t.author_id = authors.id
                  left outer join users as subjects
                    on t.subject_id = subjects.id
                  where t.claim_id = in_claim_id
                  and t.to not in (select * from unnest(filtered_states))
                  and DATE_TRUNC('day', t.created_at) > DATE_TRUNC('day', current_date - '6 months'::interval)
                )
                select t.claim_id,
                       jsonb_agg(to_jsonb(t) order by t.created_at asc) as transitions
                from transitions t
                group by t.claim_id
              ) loop
                slice := '[]'::jsonb;

                for transition in (select jsonb_array_elements(rec.transitions))
                loop
                  -- remove "deallocated" allocations as not important for report
                  if transition ->> 'to' = 'deallocated' then
                    slice := slice - -1;
                  else
                    slice := slice || transition;
                  end if;

                  -- pipe out completed slice as row
                  if transition ->> 'to' in (select * from unnest(completed_states)) then
                    journey := slice;
                    return next;
                    slice := '[]'::jsonb;
                  end if;
                end loop;

                -- pipe out last slice for claim unless it already has been above (because it has a completed status)
                if transition ->> 'to' not in (select * from unnest(completed_states)) then
                  journey := slice;
                  return next;
                end if;
              end loop;
            END
            $BODY$
            LANGUAGE plpgsql;
          SQL
        end

        def journeys_query
          <<~SQL
            SELECT
              c.*,
              c2.scheme as scheme,
              p.name as organisation,
              ct.name as case_type_name,
              c2.scheme || ' ' || c2.sub_type as bill_type,
              (c.total + c.vat_amount)::varchar as claim_total,
              journeys(c.id) as journey
            FROM claims c
            LEFT OUTER JOIN external_users AS creator
              ON c.creator_id = creator.id
            LEFT OUTER JOIN providers as p
              ON p.id = creator.provider_id
            LEFT OUTER JOIN case_types AS ct
              ON ct.id = c.case_type_id
            LEFT JOIN LATERAL (
              select
               case
                 when type in #{in_statement_for(agfs_claim_types)} then 'AGFS'
                 when type in #{in_statement_for(lgfs_claim_types)} then 'LGFS'
                 else 'Unknown'
               end as scheme,
               case
                 when regexp_replace(type, 'Claim|::|Advocate|Litigator|\s+', '', 'g') = '' then 'Final'
                 else regexp_replace(type, 'Claim|::|Advocate|Litigator|\s+', '', 'g')
               end as sub_type
              from claims
              where id = c.id
              ) c2 ON TRUE
            WHERE c.deleted_at IS NULL
              AND c.state != 'draft'
              AND c.type IN #{claim_type_filter}
          SQL
        end
      end
    end
  end
end
