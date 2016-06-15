module API
  module Entities
    class CaseType < UndatedEntity
      # Do we really need to expose all these???
      expose :id
      expose :name
      expose :is_fixed_fee
      expose :requires_cracked_dates
      expose :requires_trial_dates
      expose :allow_pcmh_fee_type
      expose :requires_maat_reference
      expose :requires_retrial_dates
      expose :roles
      expose :fee_type_code
    end
  end
end
