class Ability
  include CanCan::Ability

  def initialize(user)
    return if user.nil? || user.persona.nil?

    persona = user.persona

    if persona.is_a? SuperAdmin
      can [:show, :index, :new, :create, :edit, :update], Provider
      can [:show, :index, :new, :create, :edit, :update, :change_password, :update_password ], ExternalUser
      can [:show, :edit, :update, :change_password, :update_password], SuperAdmin, id: persona.id
      return
    end

    # applies to all external users and case workers
    can [:create, :download_attachment], Message
    can [:index, :update], UserMessageStatus

    if persona.is_a? ExternalUser
      if persona.admin?
        can [:create], ClaimIntention
        can [:show, :edit, :update, :regenerate_api_key], Provider, id: persona.provider_id
        can [:index, :outstanding, :authorised, :archived, :new, :create], Claim::BaseClaim
        can [:show, :show_message_controls, :edit, :step_2, :update, :confirmation, :clone_rejected, :destroy], Claim::BaseClaim, provider_id: persona.provider_id
        can [:show, :download], Document, provider_id: persona.provider_id
        can [:destroy], Document do |document|
          if document.external_user_id.nil?
            document.creator_id == user.id
          else
            document.external_user.provider_id == persona.provider_id
          end
        end
        can [:index, :create], Document
        can [:index, :new, :create], ExternalUser
        can [:show, :change_password, :update_password, :edit, :update, :destroy], ExternalUser, provider_id: persona.provider_id
        can [:show, :create, :update], Certification
      else
        can [:create], ClaimIntention
        can [:index, :outstanding, :authorised, :archived, :new, :create], Claim::BaseClaim
        can [:show, :show_message_controls, :edit, :step_2, :update, :confirmation, :clone_rejected, :destroy], Claim::BaseClaim, external_user_id: persona.id
        can [:show, :download], Document, external_user_id: persona.id
        can [:destroy], Document do |document|
          if document.external_user_id.nil?
            document.creator_id == user.id
          else
            document.external_user_id == persona.id
          end
        end
        can [:index, :create], Document
        can [:show, :create, :update], Certification
        can [:show, :change_password, :update_password], ExternalUser, id: persona.id
      end
    elsif persona.is_a? CaseWorker
      if persona.admin?
        can [:index, :show, :update, :archived], Claim::BaseClaim
        can [:show, :download], Document
        can [:index, :new, :create], CaseWorker
        can [:show, :show_message_controls, :edit, :change_password, :update_password, :update, :destroy], CaseWorker
        can [:new, :create], Allocation
        can :view, :management_information
      else
        can [:index, :show, :show_message_controls, :archived], Claim::BaseClaim
        can [:update], Claim::BaseClaim do |claim|
          claim.case_workers.include?(user.persona)
        end
        can [:show, :download], Document
        can [:show, :change_password, :update_password], CaseWorker, id: persona.id
      end
    end
  end
end
