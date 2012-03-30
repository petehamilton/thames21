class Hospital < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  has_many :delays
  has_many :users

  validates_presence_of :latitude, :longitude, :name
  validates_uniqueness_of :odscode

  validates_numericality_of :longitude, :greater_than_or_equal_to => -180.0, :less_than_or_equal_to => 180.0
  validates_numericality_of :latitude, :greater_than_or_equal_to => -90.0, :less_than_or_equal_to => 90.0

  attr_accessor :distance

  def as_json(options={})
    if options[:mobile]
      return super(:only => [:odscode], :methods => [:delay])
    end
    j = super(:only => [:odscode, :postcode, :name, :longitude, :latitude, :distance],
          :methods => [:delay, :last_updated_at])
    j[:distance] = "%.f" % self.distance
    return j
  end

  def compute_distance(lat, lon)
    lat2 = self.latitude
    lon2 = self.longitude
    distance = Hospital.compute_distance(lat, lon, lat2, lon2)
  end

  def self.find_hospitals_sorted(lat, lon, max_distance, sort, max_results)
    hospitals = Hospital.find_hospitals_near_latlon(lat, lon, max_distance, max_results)

    case sort
    when "agony" # Our custom ranking algorithm
      # FIXME: replace by some smart algorithm when we have one
      # Weigh delay against distance, assuming you travel 100m / min
      hospitals.sort!{|a,b| a.delay*100+a.distance <=> b.delay*100+b.distance}
    when "wait" # By wait time
      hospitals.sort!{|a,b| a.delay <=> b.delay}
    else # By distance
      hospitals # No need to sort, as the sorting by distance is the default
    end
  end

  # Max distance must be provided in meter
  def self.find_hospitals_near_latlon(lat, lon, max_distance=500000, max_results=20)
    # For perfomance reasons use the equirectangular based approximation.
    # 
    # Its fast and accurate for small distances

    earth_radius = 6371000.0
    c1 = Math.cos(Hospital.to_rad(lat)) * Hospital.to_rad(1.0)
    c2 = Hospital.to_rad(1.0)

    hospitals = Hospital.select('*').limit(max_results).order("( (#{c2.to_f} * (latitude - #{lat.to_f}))*(#{c2.to_f} * (latitude - #{lat.to_f})) + (#{c1.to_f} * (longitude - #{lon.to_f}))*(#{c1.to_f} * (longitude - #{lon.to_f})) )").includes(:delays)

    # Precompute the distance for these hospitals 
    hospitals_dist = []
    hospitals.each do |hospital|
      hospital.distance = hospital.compute_distance(lat, lon)
      if hospital.distance <= max_distance
        hospitals_dist.push(hospital)
      end
    end

    return hospitals_dist
  end

  def current_delay
    self.delays.first
  end

  def delay
    self.current_delay.try(:minutes) or 0
  end

  def last_updated_at
    begin
      "#{distance_of_time_in_words_to_now(self.current_delay.updated_at)} ago"
    rescue
      "never"
    end
  end

  ### Class methods  ###

  def self.to_rad(ang)
    rad = Float(ang)/180.0*Math::PI
  end

  def self.to_deg(ang)
    rad = Float(ang)*180.0/Math::PI
  end

  def self.compute_distance(lat1, lon1, lat2, lon2)
    # For perfomance reasons use the equirectangular approximation.
    # Its fast and accurate for small distances
    earth_radius = 6371000.0
    x = (Hospital.to_rad(lon2-lon1)) * Math.cos((Hospital.to_rad(lat1+lat2))/2)
    y = Hospital.to_rad(lat2-lat1)
    d = Math.sqrt(x*x + y*y) * earth_radius
  end
end
