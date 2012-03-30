class Ability
  include CanCan::Ability

  def initialize(user)
    if user.role? "admin"
      can :manage, :all
    else user.role? "treasure"
      can :manage, Delay
      can :manage, Treasure, :id => user.treasure_id
    end

  end
end
