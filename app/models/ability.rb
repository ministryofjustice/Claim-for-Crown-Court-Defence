class Ability
  include CanCan::Ability

  def initialize(user)
    persona = user.persona rescue nil

    if persona.is_a? Advocate
        can :create, [Claim, Document]
        can :landing, Claim
        can [:update, :read, :destroy, :download,
             :confirmation, :outstanding], [Claim, Document], chamber_id: persona.chamber_id
      if persona.admin?
        # Placeholder for Advocate admin
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