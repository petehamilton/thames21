class CreateTreasures < ActiveRecord::Migration
  def self.up
    create_table :treasures do |t|
      t.text :title
      t.text :description
      t.float :longitude
      t.float :latitude

      t.timestamps
    end
  end

  def self.down
    drop_table :treasures
  end
end
