module Tasks
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
            'Transition State',
            'Date',
            'Time difference (days)',
            'Time difference (seconds)'
          ]

          rows = query
          batch_size = 5000

          bar = ProgressBar.create(
            title: 'Archive',
            format: "%a [%e] %b\u{15E7}%i %c/%C %t",
            progress_mark: '#'.green,
            remainder_mark: "\u{FF65}".yellow,
            starting_at: 0,
            total: rows.count
          )

          rows.find_in_batches(batch_size: batch_size).with_index do |claims, i|
            claims.each_with_index do |claim, j|
              bar.increment
              main_defendant = claim.defendants.first

              transitions = claim.claim_state_transitions
              pre_archive_index = transitions.find_index do |t|
                ! Claims::StateMachine::CASEWORKER_DASHBOARD_ARCHIVED_STATES.include? t.to
              end

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
                transitions[pre_archive_index]&.to,
                transitions[pre_archive_index]&.created_at
              ]
              (pre_archive_index - 1).downto(0) do |i|
                diff = transitions[i].created_at - transitions[i+1].created_at
                csv << [nil] * 9 + [
                  transitions[i]&.to,
                  transitions[i].created_at,
                  (diff / (24*60*60)).round(2),
                  diff,
                ]
              end
            end
          end
        end
      end

      private
      def self.query
        Claim::BaseClaim.caseworker_dashboard_archived
          .includes(
            :case_type, :claim_state_transitions,
            defendants: :representation_orders,
            external_user: :user
          )
      end
    end
  end
end
