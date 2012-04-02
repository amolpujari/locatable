Geocoder = Geokit::Geocoders::GoogleGeocoder

class Location < ActiveRecord::Base
  belongs_to :locatable, :polymorphic => true

  validates_format_of :ip, :with => /^(?:(?:[2][5][0-5]|[1]?[1-9]{1,2}|0)(?:\.|$)){4}/i, :allow_blank => true
  validates_format_of :zip, :with => /^\d{5}(-\d{4})?$/i, :allow_blank => true

  after_initialize :lat

  def before_destroy
    if self.locatable
      str_err = "Cannot delete this as its belongs to #{self.locatable_type}:#{self.locatable_id}"
      errors.add :base, str_err
      raise str_err
    end
  end
  
  def citystatezip
    return self.zip unless self.zip.blank?
    return self.city unless self.city.blank?
    return self.state
  end

  def address
    _address = read_attribute(:address)
    return _address if _address
    return [self.street, self.city, self.state, self.zip].compact.join ', '
  end

  def full_address
    items = [self.address || self.street || '']
    str = items.to_s.downcase
    items << self.zip unless str.include? self.zip rescue nil
    items << self.city unless str.include? self.city.downcase rescue nil
    items << self.state unless str.include? self.state.downcase rescue nil

    str = items.compact.join ', '
    
    # to remove state_abbreviation
    matches = " #{str} ".scan(/[^A-Za-z][A-Za-z]{2}[^A-Za-z]/)
    matches.each do |match|
      States.keys.include? match.strip.upcase rescue nil
      str.sub! match.strip, ''
    end rescue nil
    
    str.gsub('  ', ' ')
  end

  def address= _address
    _address = _address.to_s.strip rescue nil
    _address = nil if _address.length==0 rescue nil
    return if _address.blank?
    
    _ip = (_address.match /^(?:(?:[2][5][0-5]|[1]?[1-9]{1,2}|0)(?:\.|$)){4}/).to_s rescue nil
    unless _ip.blank?
      self.ip = _ip
      return
    end

    _zip = (_address.match /^\d{5}(-\d{4})?$/).to_s rescue nil
    unless _zip.blank?
      self.zip = _zip
    end

    write_attribute(:address, _address)
  end
  
  def lat
    value = read_attribute(:lat)
    return value.to_f if value
    fetch_lat_lng[:lat]
  end

  def lng
    value = read_attribute(:lng)
    return value.to_f if value
    fetch_lat_lng[:lng]
  end

  def zip(fetch_it=false)
    value = read_attribute(:zip)
    return value if value
    value = fetch_zip if fetch_it
  end

  alias :latitude :lat
  alias :longitude :lng
  alias :long :lng

  def self.new(attributes=nil)
    if attributes.is_a? Hash
      obj = super attributes rescue nil
    else
      obj = super(:address => attributes.to_s) rescue nil
    end
    return nil if obj.lat.blank?
    obj
  end

  def state_abbreviation=value
    value = value.to_s.strip rescue ''
    value = nil if value.size != 2
    write_attribute(:state_abbreviation, value)
  end

  def state=value
    value = value.to_s.strip rescue ''
    self.state_abbreviation = value
    value = States[value.upcase] || value if value.length == 2 rescue value
    write_attribute(:state, value)
  end

  private

  def fetch_lat_lng
    data = {:lat => nil, :lng => nil}

    if not self.address or self.address.length < 2
      if not self.ip or self.ip.length < 10 # 9 => 127.0.0.1
        return data
      else
        geoloc = IpGeocoder.geocode self.ip
      end
    else
      geoloc = Geocoder.geocode self.address
    end

    unless geoloc.success
      puts "---------geocode fails for address: #{self.address}"
      return data
    end

    geoloc = Geocoder.reverse_geocode ([geoloc.lat, geoloc.lng]) if geoloc.zip.blank?
    data = {:lat => geoloc.lat, :lng => geoloc.lng}

    data.merge!({ :city               => geoloc.city    }) if self.city.blank?
    data.merge!({ :zip                => geoloc.zip     }) #if self.zip.blank?
    data.merge!({ :state              => geoloc.state   }) if self.state.blank?
    data.merge!({ :state_abbreviation => geoloc.state   }) #if self.state_abbreviation.blank?
    data.merge!({ :country            => geoloc.country }) if self.country.blank?

    self.attributes = data

    data
  end

  def fetch_zip
    geoloc = Geocoder.reverse_geocode ([self.lat, self.lng])
    return unless geoloc

    data = {}
    data.merge!({ :city               => geoloc.city    }) if self.city.blank?
    data.merge!({ :zip                => geoloc.zip     }) #if self.zip.blank?
    data.merge!({ :state              => geoloc.state   }) if self.state.blank?
    data.merge!({ :state_abbreviation => geoloc.state   }) #if self.state_abbreviation.blank?
    data.merge!({ :country            => geoloc.country }) if self.country.blank?

    self.attributes = data
    geoloc.zip
  end

  States = {
    "AL" => "Alabama",
    "AK" => "Alaska",
    "AZ" => "Arizona",
    "AR" => "Arkansas",
    "CA" => "California",
    "CO" => "Colorado",
    "CT" => "Connecticut",
    "DE" => "Delaware",
    "FL" => "Florida",
    "GA" => "Georgia",
    "HI" => "Hawaii",
    "ID" => "Idaho",
    "IL" => "Illinois",
    "IN" => "Indiana",
    "IA" => "Iowa",
    "KS" => "Kansas",
    "KY" => "Kentucky",
    "LA" => "Louisiana",
    "ME" => "Maine",
    "MD" => "Maryland",
    "MA" => "Massachusetts",
    "MI" => "Michigan",
    "MN" => "Minnesota",
    "MS" => "Mississippi",
    "MO" => "Missouri",
    "MT" => "Montana",
    "NE" => "Nebraska",
    "NV" => "Nevada",
    "NH" => "New Hampshire",
    "NJ" => "New Jersey",
    "NM" => "New Mexico",
    "NY" => "New York",
    "NC" => "North Carolina",
    "ND" => "North Dakota",
    "OH" => "Ohio",
    "OK" => "Oklahoma",
    "OR" => "Oregon",
    "PA" => "Pennsylvania",
    "RI" => "Rhode Island",
    "SC" => "South Carolina",
    "SD" => "South Dakota",
    "TN" => "Tennessee",
    "TX" => "Texas",
    "UT" => "Utah",
    "VT" => "Vermont",
    "VA" => "Virginia",
    "WA" => "Washington",
    "WV" => "West Virginia",
    "WI" => "Wisconsin",
    "WY" => "Wyoming",
    "AS" => "American Samoa",
    "DC" => "District of Columbia",
    "GU" => "Guam",
    "MP" => "Northern Mariana Islands",
    "PR" => "Puerto Rico",
    "VI" => "Virgin Islands"
  }
end









