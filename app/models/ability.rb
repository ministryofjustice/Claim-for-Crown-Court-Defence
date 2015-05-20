class Ability
  include CanCan::Ability

  def initialize(user)
    persona = user.persona rescue nil

    if persona.is_a? Advocate
      if persona.admin?
        can :manage, :all
      else
        can :manage, Claim
        can :manage, Document, chamber_id: persona.chamber_id
      end
    elsif persona.is_a? CaseWorker
      if persona.admin?
        can :manage, :all
      else
        can :manage, [Claim, Document]
      end
    end
  end
end
