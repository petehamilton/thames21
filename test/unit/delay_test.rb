require 'test_helper'

class DelayTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  
  test "validation" do

    delay = Delay.new :minutes => 12, :hospital_id => -1
    assert !delay.valid?

    hospital = Hospital.new :name => "Test", :longitude => 0.0, :latitude => 0.0
    hospital.save

    delay = Delay.new :minutes => -12, :hospital => hospital 
    assert !delay.valid?

    delay = Delay.new :minutes => 0, :hospital => hospital 
    assert delay.save

    delay.reload
    hospital.reload

    assert delay.hospital.id == hospital.id
    assert hospital.delays.first.id == delay.id
  end

end
