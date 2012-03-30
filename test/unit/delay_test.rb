require 'test_helper'

class DelayTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  
  test "validation" do

    delay = Delay.new :minutes => 12, :treasure_id => -1
    assert !delay.valid?

    treasure = Treasure.new :name => "Test", :longitude => 0.0, :latitude => 0.0
    treasure.save

    delay = Delay.new :minutes => -12, :treasure => treasure 
    assert !delay.valid?

    delay = Delay.new :minutes => 0, :treasure => treasure 
    assert delay.save

    delay.reload
    treasure.reload

    assert delay.treasure.id == treasure.id
    assert treasure.delays.first.id == delay.id
  end

end
