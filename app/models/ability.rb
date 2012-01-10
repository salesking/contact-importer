class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      can :manage, Attachment, company_id: user.company_id
      can :manage, Mapping, company_id: user.company_id
      can :manage, Import, company_id: user.company_id
    end
  end
end
