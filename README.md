# Gecode Locatable

Dealing with location based services, or location centric app. Or do you need current_location like current_user in your app?

Or what about having a location model like this one

```ruby
1.9.2p290 :002 > location = Location.new 'Patricia Drive, San Antonio'
#<Location:0x000000035f5610> {
                    :id => nil,
          :locatable_id => nil,
        :locatable_type => nil,
                    :ip => nil,
               :country => "US",
                 :state => "Texas",
    :state_abbreviation => "TX",
                :county => nil,
                  :city => "San Antonio",
                :street => nil,
               :address => "Patricia Drive, San Antonio",
                   :zip => "78205",
                   :lat => 29.423901,
                   :lng => -98.493301,
            :created_at => nil,
            :updated_at => nil
}
1.9.2p290 :003 > location = Location.new '209.59.160.0'
#<Location:0x00000003548ff0> {
                    :id => nil,
          :locatable_id => nil,
        :locatable_type => nil,
                    :ip => nil,
               :country => "US",
                 :state => "Kansas",
    :state_abbreviation => "KS",
                :county => nil,
                  :city => "Woodston",
                :street => nil,
               :address => "209.59.160.0",
                   :zip => "67675",
                   :lat => 39.527596,
                   :lng => -99.141968,
            :created_at => nil,
            :updated_at => nil
}
1.9.2p290 :004 >
```

And then ....

```ruby
class House < ActiveRecord::Base
  locatable
end

#will make it like...

@house = House.new
@house.location = Location.new '9737 Forest Lane Dallas'
@house.zip # => 75201
```

### Note that

 * It is using google geocode inside, which should be configurable to switch to any other service like yahoo or mapquest
 * it has lat/lng so can be put on maps
 * it has zip, so can be used to called any other geolocation based service, those mostly accept city/state/zip/address


