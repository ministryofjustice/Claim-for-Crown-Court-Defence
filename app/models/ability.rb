class Ability
  include CanCan::Ability

  def initialize(user)
    return if user.nil? || user.persona.nil?

    persona = user.persona

    if persona.is_a? SuperAdmin
      can %i[show index new create edit update], Provider
      can %i[show index new create edit update change_password update_password], ExternalUser
      can %i[show edit update change_password update_password], SuperAdmin, id: persona.id
      can [:update_settings], User, id: user.id
      return
    end

    # applies to all external users and case workers
    can %i[create download_attachment], Message
    can %i[index update], UserMessageStatus
    can [:update_settings], User, id: user.id

    send(persona_type(persona), persona)
  end

  private

  def external_user_admin(persona)
    can_administer_any_claim_in_provider(persona)
    can_administer_provider(persona)
  end

  def external_user(persona)
    # NOTE: privleges on AGFS and LGFS claims are cumulative since you can have privs for both
    can_manage_advocate_claims(persona) if persona.advocate?
    can_manage_litigator_claims(persona) if persona.litigator?
    can_manage_own_password(persona)
    can_manage_self(persona)
  end

  def case_worker_admin(_persona)
    can %i[index show update archived], Claim::BaseClaim
    can %i[show download], Document
    can %i[index new create], CaseWorker
    can %i[show show_message_controls edit change_password update_password update destroy], CaseWorker
    can %i[new create], Allocation
    can :view, :management_information
  end

  def case_worker(persona)
    can %i[index show show_message_controls archived], Claim::BaseClaim
    can [:update], Claim::BaseClaim do |claim|
      claim.case_workers.include?(persona)
    end
    can %i[show download], Document
    can_manage_own_password(persona)
  end

  def persona_type(persona)
    persona_suffix = persona.admin? ? '_admin' : ''
    if persona.is_a?(ExternalUser)
      "external_user#{persona_suffix}"
    elsif persona.is_a?(CaseWorker)
      "case_worker#{persona_suffix}"
    end
  end

  def can_administer_any_claim_in_provider(persona)
    can [:create], ClaimIntention
    can %i[index outstanding authorised archived new create], Claim::BaseClaim
    can %i[show show_message_controls messages edit update summary unarchive confirmation clone_rejected destroy], Claim::BaseClaim, provider_id: persona.provider_id
    can %i[show create update], Certification
    can_administer_documents_in_provider(persona)
  end

  def can_administer_documents_in_provider(persona)
    can %i[index create], Document

    # NOTE: for destroy action, at least, the document may not be persisted/saved
    can %i[show download destroy], Document do |document|
      if document.external_user_id.nil?
        User.active.find(document.creator_id).persona.provider.id == persona.provider.id
      else
        document.external_user.provider.id == persona.provider.id
      end
    end
  end

  def can_administer_provider(persona)
    can %i[show edit update regenerate_api_key], Provider, id: persona.provider_id
    can %i[index new create], ExternalUser
    can %i[show change_password update_password edit update destroy], ExternalUser, provider_id: persona.provider_id
  end

  def can_manage_litigator_claims(persona)
    can_manage_own_claims_of_class(persona, [Claim::LitigatorClaim, Claim::InterimClaim, Claim::TransferClaim])
  end

  def can_manage_advocate_claims(persona)
    can_manage_own_claims_of_class(persona, Claim::AdvocateClaim)
  end

  def can_manage_own_claims_of_class(persona, claim_klass)
    can [:create], ClaimIntention
    can %i[index outstanding authorised archived new create], claim_klass
    can %i[show show_message_controls messages edit update summary unarchive confirmation clone_rejected destroy], claim_klass, external_user_id: persona.id
    can %i[show create update], Certification
    can_manage_own_documents(persona)
  end

  def can_manage_own_documents(persona)
    can %i[index create], Document
    can %i[show download destroy], Document do |document|
      if document.external_user_id.nil?
        document.creator_id == persona.user.id
      else
        document.external_user_id == persona.id
      end
    end
  end

  def can_manage_own_password(persona)
    can %i[show change_password update_password], persona.class, id: persona.id
  end

  def can_manage_self(persona)
    can %i[show edit update], persona.class, id: persona.id
  end
end
