class Ability
  include CanCan::Ability

  def initialize(user)
    return if user.nil? || user.persona.nil?

    persona = user.persona

    can [:create], Message
    can [:index, :update], UserMessageStatus

    if persona.is_a? Advocate
      if persona.admin?
        can [:index, :landing, :outstanding, :authorised, :new, :create], Claim
        can [:show, :edit, :update, :confirmation, :destroy], Claim, chamber_id: persona.chamber_id
        can [:show, :download], Document, chamber_id: persona.chamber_id
        can [:show, :download], RepresentationOrder, chamber_id: persona.chamber_id
        can [:index, :new, :create], Advocate
        can [:show, :edit, :update, :destroy], Advocate, chamber_id: persona.chamber_id
      else
        can [:index, :landing, :outstanding, :authorised, :new, :create], Claim
        can [:show, :edit, :update, :confirmation, :destroy], Claim, advocate_id: persona.id
        can [:show, :download], Document, advocate_id: persona.id
        can [:show, :download], RepresentationOrder, advocate_id: persona.id
      end
    elsif persona.is_a? CaseWorker
      if persona.admin?
        can [:index, :show, :update], Claim
        can [:show, :download], Document
        can [:show, :download], RepresentationOrder
        can [:index, :new, :create], CaseWorker
        can [:show, :edit, :allocate, :update, :destroy], CaseWorker
      else
        can [:index, :show], Claim
        can [:update], Claim do |claim|
          claim.case_workers.include?(user.persona)
        end
        can [:show, :download], Document
        can [:show, :download], RepresentationOrder
        can [:show], CaseWorker, id: persona.id
      end
    end
  end
end
