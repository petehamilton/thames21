class Ability
  include CanCan::Ability

  def initialize(user)
    if user.role? "admin"
      can :manage, :all
    else user.role? "hospital"
      can :manage, Delay
      can :manage, Hospital, :id => user.hospital_id
    end

  end
end
