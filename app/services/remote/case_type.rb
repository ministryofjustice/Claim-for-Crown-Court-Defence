module Remote
  class CaseType < Base

    attr_accessor :name,
                  :is_fixed_fee,
                  :requires_cracked_dates,
                  :requires_trial_dates,
                  :allow_pcmh_fee_type,
                  :requires_maat_reference,
                  :requires_retrial_dates,
                  :roles,
                  :fee_type_code

    class << self
      def resource_path
        'case_types'
      end

      # TODO: following methods will be extracted to a new (non-ActiveRecord) Roles concern
      #
      def lgfs
        all.select { |ct| ct.roles.include?('lgfs') }
      end

      def agfs
        all.select { |ct| ct.roles.include?('agfs') }
      end

      def interims
        all.select { |ct| ct.roles.include?('interim') }
      end
    end
  end
end
