module ExternalUsers
  module ClaimTypesHelper
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
