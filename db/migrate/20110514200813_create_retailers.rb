class CreateRetailers < ActiveRecord::Migration
  def self.up
    create_table :retailers do |t|
      t.string :name
      t.decimal :lat
      t.decimal :lon
      t.string :street
      t.string :city
      t.string :state
      t.string :zip
      t.string :zip_plus_four

      t.timestamps
    end
  end

  def self.down
    drop_table :retailers
  end
end
