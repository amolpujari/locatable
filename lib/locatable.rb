module LocatableBase
  module ClassMethods
    def locatable
      has_one :location, :as=>:locatable, :dependent=>:destroy
      extend LocatableModule::ClassMethods
      include LocatableModule::InstanceMethods
    end
  end
end

module LocatableModule
  module ClassMethods

    # get you all states recorded so far
    def states
      polymorphic_association = " FROM locations, #{self.table_name} locatable where locations.locatable_id = locatable.id and locations.locatable_type = '#{self.name}' "

      hash_nbs = self.find_by_sql ["SELECT distinct state #{polymorphic_association}", 'state']
      hash_nbs = hash_nbs.collect {|nb| nb['state']}
      hash_nbs.compact.sort
    end

    # get you all cities recorded so far
    def cities(state=nil)
      state = state.to_s rescue nil
      state_condition = state.blank? ? '' : " and locations.state='#{state}' "

      polymorphic_association = " FROM locations, #{self.table_name} locatable where locations.locatable_id = locatable.id and locations.locatable_type = '#{self.name}' "

      hash_nbs = self.find_by_sql ["SELECT distinct city #{polymorphic_association} #{state_condition}", 'city']
      hash_nbs = hash_nbs.collect {|nb| nb['city']}
      hash_nbs.compact.sort
    end

    def find_by_state_and_city(state=nil, city=nil)
      state = state.to_s rescue nil
      state_condition = state.blank? ? '' : " and locations.state='#{state}' "

      city = city.to_s rescue nil
      city_condition = city.blank? ? '' : " and locations.city='#{city}' "

      polymorphic_association = " FROM locations, #{self.table_name} locatable where locations.locatable_id = locatable.id and locations.locatable_type = '#{self.name}' "

      self.find_by_sql "select locatable.* #{polymorphic_association} #{state_condition} #{city_condition}"
    end

    def find_by_city(city=nil)
      city = city.to_s rescue nil
      city_condition = city.blank? ? '' : " and locations.city='#{city}' "

      polymorphic_association = " FROM locations, #{self.table_name} locatable where locations.locatable_id = locatable.id and locations.locatable_type = '#{self.name}' "

      self.find_by_sql "select locatable.* #{polymorphic_association} #{city_condition}"
    end
  end

  module InstanceMethods
    def city
      self.location.city rescue nil
    end

    def address
      self.location.address rescue nil
    end

    def full_address
      self.location.full_address rescue nil
    end

    def citystatezip
      self.location.citystatezip rescue nil
    end

    def state
      self.location.state rescue nil
    end

    def state_abbreviation
      self.location.state_abbreviation rescue nil
    end

    def country
      self.location.country rescue nil
    end

    def county
      self.location.county rescue nil
    end

    def street
      self.location.street rescue nil
    end

    def zip
      self.location.zip rescue nil
    end

    def lat
      self.location.lat rescue nil
    end

    def lng
      self.location.lng rescue nil
    end

    alias :latitude :lat
    alias :longitude :lng
    alias :long :lng
    
  end
end
