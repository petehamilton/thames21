require 'json'

namespace :test_data do

  desc "Removes all delay time data"
  task :remove_delay_time => :environment do
    Delay.delete_all
  end

  desc "Creates delay time test data"
  task :create_delay_time => :environment do
    # Use a transaction to speed up the mass insertion, see http://www.coffeepowered.net/2009/01/23/mass-inserting-data-in-rails-without-killing-your-performance/
    ActiveRecord::Base.transaction do
      Hospital.all.each do |hospital|
        for i in 0..8
          delay = Delay.new(:hospital => hospital)
          # Change the creation of the delay object to be i days in the past
          delay.created_at = delay.created_at - i.days
          delay.updated_at = delay.created_at
          # The waiting time is a randomized sinus function ...
          minutes = 1 + Math.sin( Random.rand(1)*i + Random.rand(2*3.14) )
          # ... to which we add a random variation ...
          minutes = 75*minutes + Random.rand(10)
          # ... and ensure that it is positive.
          delay.minutes = [0, minutes].max 
          delay.save
        end
      end
    end
  end

  desc "Run all test data tasks"
  task :all => [:remove_delay_time, :create_delay_time]
end
