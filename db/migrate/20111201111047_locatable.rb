class Locatable < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.integer     :locatable_id
      t.string      :locatable_type

			t.string      :ip

			t.string      :country
			t.string      :state
			t.string      :state_abbreviation
			t.string      :county
			t.string      :city
      t.string      :street
      t.string      :address

			t.string      :zip
			t.float       :lat
			t.float       :lng
      
			t.timestamps
    end
    
    execute("ALTER TABLE locations MODIFY lat numeric(15,10);")
    execute("ALTER TABLE locations MODIFY lng numeric(15,10);")
  end

  def self.down
    drop_table :locations
  end
end
