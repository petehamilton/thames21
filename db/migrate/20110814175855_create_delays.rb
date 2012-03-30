class CreateDelays < ActiveRecord::Migration
  def self.up
    create_table :delays do |t|
      t.integer :hospital_id
      t.integer :minutes

      t.timestamps
    end
  end

  def self.down
    drop_table :delays
  end
end
