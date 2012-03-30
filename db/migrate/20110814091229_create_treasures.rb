class CreateTreasures < ActiveRecord::Migration
  def self.up
    create_table :treasures do |t|
      t.text :name
      t.text :description
      t.text :hyperlink
      t.float :lat
      t.float :lng

      t.timestamps
    end
  end

  def self.down
    drop_table :treasures
  end
end
