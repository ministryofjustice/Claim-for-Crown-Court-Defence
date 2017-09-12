module API
  module V2
    class Search < Grape::API
      helpers API::V2::CriteriaHelper
      before_validation do
        authenticate_user_is?('CaseWorker')
      end

      resource :search, desc: 'Search for claims' do
        params do
          optional :api_key, type: String, desc: 'REQUIRED: The API authentication key of the user'
          optional :scheme,
                   type: String,
                   values: %w[agfs lgfs],
                   default: 'agfs',
                   desc: 'OPTIONAL: This will be used to filter the list of unallocated claims'
        end

        helpers do
          def claims
            built_sql = unallocated_sql.gsub(/REPLACE_MATCHER/, scheme.eql?('agfs') ? ' = ' : ' != ')
            result = ActiveRecord::Base.connection.execute(built_sql).to_a
            JSON.parse(result.to_json, object_class: OpenStruct)
          end

          def scheme
            params.scheme
          end

          def unallocated_sql
            <<~SQL
              SELECT
                c.id,
                c.uuid,
                CASE WHEN c.type = 'Claim::AdvocateClaim' THEN 'agfs' ELSE 'lgfs' END AS scheme,
                CASE
                  WHEN ltrim(replace(type, 'Claim', ''), '::') = 'Litigator'
                  THEN 'Final' ELSE ltrim(replace(type, 'Claim', ''), '::')
                  END AS scheme_type,
                c.case_number,
                c.state,
                court.name AS court_name,
                CASE WHEN ct.name IS NULL THEN 'Transfer' ELSE ct.name END as case_type,
                SUM(c.total + c.vat_amount)/COUNT(c.id) as total,
                c.disk_evidence,
                u.first_name || ' ' || u.last_name AS external_user,
                string_agg(ro.maat_reference, ', ') AS maat_references,
                string_agg(d.first_name || ' ' || d.last_name, ', ') as defendants,
                (
                  SELECT string_agg(fees.quantity || '~' || ft.description || '~' || ft.type, ', ')
                  FROM fee_types ft INNER JOIN fees ON fees.fee_type_id = ft.id
                  WHERE fees.claim_id = c.id
                ) AS fees,
                c.last_submitted_at,
                oc.class_letter,
                ct.is_fixed_fee,
                ct.fee_type_code,
                (
                  SELECT string_agg(unique_code, ',')
                  FROM fee_types
                  WHERE type IN ('Fee::GraduatedFeeType')
                ) AS graduated_fee_types,
                c.allocation_type
              FROM claims AS c
                LEFT OUTER JOIN defendants AS d
                  ON c.id = d.claim_id
                LEFT OUTER JOIN representation_orders AS ro
                  on d.id = ro.defendant_id
                LEFT OUTER JOIN external_users AS eu
                  on c.external_user_id = eu.id
                LEFT OUTER JOIN users as u
                  ON u.id = eu.provider_id
                LEFT OUTER JOIN courts AS court
                  ON c.court_id = court.id
                LEFT OUTER JOIN case_types AS ct
                  ON c.case_type_id = ct.id
                LEFT OUTER JOIN offences AS o
                  ON c.offence_id = o.id
                LEFT OUTER JOIN offence_classes AS oc
                  ON o.offence_class_id = oc.id
              WHERE
                c.deleted_at IS NULL
                AND c.type REPLACE_MATCHER 'Claim::AdvocateClaim'
                AND c.state IN ('submitted', 'redetermination' ,'awaiting_written_reasons')
              GROUP BY
                c.id, c.uuid, c.allocation_type, court.name,
                ct.name, ct.is_fixed_fee, ct.fee_type_code, c.disk_evidence,
                u.first_name, u.last_name, oc.class_letter
              ;
            SQL
          end
        end

        resource :unallocated do
          desc 'Retrieve list of unallocated claims'
          get do
            present claims, with: API::Entities::SearchResult, user: current_user, content_encoding: 'gzip'
          end
        end
      end
    end
  end
end
