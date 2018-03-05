module ExternalUsers
  module ClaimTypesHelper
    def claim_type_prompt_heading_for(user)
      if user.persona.has_roles?('admin')
        t('external_users.claim_heading')
      elsif user.persona.has_roles?('advocate')
        t('external_users.agfs_claim_heading')
      elsif user.persona.has_roles?('litigator')
        t('external_users.lgfs_claim_heading')
      else
        t('external_users.claim_heading')
      end
    end
  end
end
