module Claims::MI
  module Queries
    extend Grape::API::Helpers

    def scheme_ten_claims(start_date, end_date)
      <<~SQL
        SELECT DISTINCT
          c.id,
          c.type,
          d.first_name || ' ' || d.last_name as defendant,
          c.case_number,
          c.last_submitted_at AS claim_submitted,
          ct.name as case_type,
          courts.name AS court,
          o.description AS offence,
          ob.description as offence_band,
          p.name as provider_name,
          u.first_name || ' ' || u.last_name AS user_name,
          ro.created_at,
          ro.representation_order_date
        FROM claims c
          INNER JOIN case_types ct ON ct.id = c.case_type_id
          INNER JOIN defendants d ON d.claim_id = c.id
            INNER JOIN representation_orders ro ON ro.defendant_id = d.id
          INNER JOIN courts ON courts.id = c.court_id
          LEFT OUTER JOIN offences o on o.id = c.offence_id
            LEFT OUTER JOIN offence_bands ob ON o.offence_band_id = ob.id
          INNER JOIN external_users eu ON eu.id = c.external_user_id
            INNER JOIN users u ON u.persona_id = eu.id
            INNER JOIN providers p ON p.id = eu.provider_id
        WHERE
          c.last_submitted_at BETWEEN #{start_date} AND #{end_date}
          AND c.type LIKE 'Claim::Advocate%'
          AND ro.representation_order_date >= '2018-04-01'
          AND c.state != 'draft'
        ORDER BY ro.created_at ASC, c.case_number ASC;
      SQL
    end
  end
end
