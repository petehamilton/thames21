class CreateHospitals < ActiveRecord::Migration
  def self.up
    create_table :hospitals do |t|
      t.string :source_uri
      t.string :name
      t.string :index_letter
      t.string :rights
      t.text :summary
      t.datetime :published
      t.datetime :updated
      t.string :odscode
      t.string :parent_organisation_name
      t.string :parent_organisation_uri
      t.string :address_line1
      t.string :address_line2
      t.string :address_line3
      t.string :address_line4
      t.string :address_line5
      t.string :postcode
      t.string :telephone
      t.string :fax
      t.string :email
      t.string :website_url
      t.integer :northing
      t.integer :easting
      t.float :longitude
      t.float :latitude

      t.timestamps
    end
  end

  def self.down
    drop_table :hospitals
  end
end
