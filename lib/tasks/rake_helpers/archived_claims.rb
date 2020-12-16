module RakeHelpers
  module ArchivedClaims
    def self.write filename
      CSV.open(filename, 'wb') do |csv|
        csv << [
          'Claim type',
          'Case number',
          'Advocate/Litigator',
          'Main defendant',
          'MAAT',
          'Total (inc VAT)',
          'Status',
          'Case type',
          'Submitted',
          'Archived date'
        ]

        rows = query
        batch_size = 5000
        total = rows.count
        rows.find_in_batches(batch_size: batch_size).with_index do |claims, i|
          claims.each_with_index do |claim, j|
            print "\r - #{i*batch_size + j} of #{total} claims written".yellow if j % 73 == 0
            main_defendant = claim.defendants.first
            csv << [
              claim.pretty_type,
              claim.case_number,
              claim.external_user.name,
              main_defendant&.name,
              main_defendant&.representation_orders&.map(&:maat_reference)&.join(', '),
              claim.total + claim.vat_amount,
              claim.state.humanize,
              claim.case_type&.name || 'N/A',
              claim.last_submitted_at,
              claim.archived_claim_state_transitions&.first&.created_at
            ]
          end
          print "\r - #{(i+1)*batch_size} of #{total} claims written".yellow
        end
        puts "\r - #{total} claims written          ".green
      end
    end

    private
    def self.query
      Claim::BaseClaim.caseworker_dashboard_archived
        .includes(
          :case_type, :archived_claim_state_transitions,
          defendants: :representation_orders,
          external_user: :user
        )
    end
  end
end
