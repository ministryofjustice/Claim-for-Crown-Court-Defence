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
        can_administer_any_claim_in_provider(persona)
        can_administer_provider(persona)
      else
        # NOTE: privleges on AGFS and LGFS claims are cumulative since you can have privs for both
        if persona.advocate?
          can_manage_own_claims_of_class(persona, Claim::AdvocateClaim)
        end

        if persona.litigator?
          can_manage_own_claims_of_class(persona, Claim::LitigatorClaim)
        end

        can_manage_own_password(persona)
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
          claim.case_workers.include?(persona)
        end
        can [:show, :download], Document
        can_manage_own_password(persona)
      end
    end
  end

  private

  def can_administer_any_claim_in_provider(persona)
    can [:create], ClaimIntention
    can [:index, :outstanding, :authorised, :archived, :new, :create], Claim::BaseClaim
    can [:show, :show_message_controls, :edit, :update, :summary, :unarchive, :confirmation, :clone_rejected, :destroy], Claim::BaseClaim, provider_id: persona.provider_id
    can [:show, :create, :update], Certification
    can_administer_documents_in_provider(persona)
  end

  def can_administer_documents_in_provider(persona)
    can [:index, :create], Document

    # NOTE: for destroy action, at least, the document may not be persisted/saved
    can [:show, :download, :destroy], Document do |document|
      if document.external_user_id.nil?
        User.find(document.creator_id).persona.provider.id == persona.provider.id
      else
        document.external_user.provider.id == persona.provider.id
      end
    end
  end

  def can_administer_provider(persona)
    can [:show, :edit, :update, :regenerate_api_key], Provider, id: persona.provider_id
    can [:index, :new, :create], ExternalUser
    can [:show, :change_password, :update_password, :edit, :update, :destroy], ExternalUser, provider_id: persona.provider_id
  end

  # NOTE: advocate claims "owned" by external_user, litigators "owned" by creator
  def can_manage_own_claims_of_class(persona, claim_klass)
    can [:create], ClaimIntention
    can [:index, :outstanding, :authorised, :archived, :new, :create], claim_klass
    claim_klass == Claim::LitigatorClaim ? claim_owner_id_attr = 'creator_id' : claim_owner_id_attr = 'external_user_id'
    can [:show, :show_message_controls, :edit, :update, :summary, :unarchive, :confirmation, :clone_rejected, :destroy], claim_klass, claim_owner_id_attr => persona.id
    can [:show, :create, :update], Certification
    can_manage_own_documents(persona)
  end

  def can_manage_own_documents(persona)
    can [:index, :create], Document
    can [:show, :download, :destroy], Document do |document|
      if document.external_user_id.nil?
        document.creator_id == persona.user.id
      else
        document.external_user_id == persona.id
      end
    end
  end

  def can_manage_own_password(persona)
    can [:show, :change_password, :update_password], persona.class, id: persona.id
  end

end