class User < ActiveRecord::Base

  has_and_belongs_to_many :roles
  belongs_to :hospital

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  after_create :set_default_role

  def role?(role)
    return !!self.roles.find_by_name(role.to_s)
  end

  def set_default_role
    RolesUser.create(:user_id => self.id, :role_id => Role.find_by_name('guest').id)
  end

end
