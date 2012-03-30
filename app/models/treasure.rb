class Treasure < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  attr_accessor :distance

  def as_json(options={})
    if options[:mobile]
      return super(:only => [:odscode], :methods => [:delay])
    end
    j = super(:only => [:odscode, :postcode, :name, :lng, :lat, :distance],
          :methods => [:delay, :last_updated_at])
    j[:distance] = "%.f" % (self.distance || 0)
    return j
  end

  def compute_distance(lat, lng)
    lat2 = self.lat
    lng2 = self.lng
    distance = Treasure.compute_distance(lat, lng, lat2, lng2)
  end

  def self.find_treasures_sorted(lat, lng, max_distance, sort, max_results)
    treasures = Treasure.find_treasures_near_latlng(lat, lng, max_distance, max_results)
    return treasures
  end

  # Max distance must be provided in meter
  def self.find_treasures_near_latlng(lat, lng, max_distance=500000, max_results=20)
    puts "#{lat}, #{lng}"
    # For perfomance reasons use the equirectangular based approximation.
    #
    # Its fast and accurate for small distances

    earth_radius = 6371000.0
    c1 = Math.cos(Treasure.to_rad(lat)) * Treasure.to_rad(1.0)
    c2 = Treasure.to_rad(1.0)

    # treasures = Treasure.select('*').limit(max_results).order("( (#{c2.to_f} * (lat - #{lat.to_f}))*(#{c2.to_f} * (lat - #{lat.to_f})) + (#{c1.to_f} * (lng - #{lng.to_f}))*(#{c1.to_f} * (lng - #{lng.to_f})) )")
    treasures = Treasure.all
    # Precompute the distance for these treasures
    treasures_dist = []
    treasures.each do |treasure|
      treasure.distance = treasure.compute_distance(lat, lng)
      if treasure.distance <= max_distance
        treasures_dist.push(treasure)
      end
    end

    return treasures_dist
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

  def self.compute_distance(lat1, lng1, lat2, lng2)
    # For perfomance reasons use the equirectangular approximation.
    # Its fast and accurate for small distances
    earth_radius = 6371000.0
    x = (Treasure.to_rad(lng2-lng1)) * Math.cos((Treasure.to_rad(lat1+lat2))/2)
    y = Treasure.to_rad(lat2-lat1)
    d = Math.sqrt(x*x + y*y) * earth_radius
  end
end
