module ExternalUsers
  module ClaimTypesHelper
    def claim_type_prompt_heading_for(user)
      if user.persona.has_roles?('advocate')
        t('external_users.agfs_claim_heading')
      elsif user.persona.has_roles?('litigator')
        t('external_users.lgfs_claim_heading')
      else
        t('external_users.claim_heading')
      end
    end

    def claim_type_page_header(user)
      if user.persona.roles.eql?(['advocate'])
        t('.page_title_advocate')
      elsif user.persona.roles.eql?(['litigator'])
        t('.page_title_litigator')
      else
        t('.page_title_generic')
      end
    end
  end
end
