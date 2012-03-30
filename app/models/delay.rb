class Delay < ActiveRecord::Base
  belongs_to :hospital
  after_initialize :init

  validates_numericality_of :minutes, :greater_than_or_equal_to => 0
  validates_presence_of :hospital
  
  default_scope :order => 'created_at DESC'

  def init
    self.minutes    ||= 0.0 #will set the default value only if it's nil
    self.created_at ||= Time.now
    self.updated_at ||= Time.now
  end

end
