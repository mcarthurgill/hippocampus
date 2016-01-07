class Address < ActiveRecord::Base
  # -- ATTRS
  attr_accessible :city, :local_key, :object_type, :phone, :state, :street, :street_two, :zip, :country

  # -- MODULES
  extend Formatting
  include Formatting

  # -- CREATORS  
  def self.create_with_params params
    phone_number = params.has_key?(:phone) && params[:phone].length > 0 ? format_phone(params[:phone]) : nil
    street = params.has_key?(:street) && params[:street].length > 0 ? params[:street] : nil
    street_two = params.has_key?(:street_two) && params[:street_two].length > 0 ? params[:street_two] : nil
    city = params.has_key?(:city) && params[:city].length > 0 ? params[:city] : nil
    state = params.has_key?(:state) && params[:state].length > 0 ? params[:state] : nil
    zip = params.has_key?(:zip) && params[:zip].length > 0 ? params[:zip] : nil
    country = params.has_key?(:country) && params[:country].length > 0 ? params[:country] : nil

    a = Address.find_or_initialize_by_phone_and_street(phone_number, street)

    if a.new_record? 
      if phone_number && street && city && state && zip && country
        a.street = street
        a.street_two = street_two
        a.city = city
        a.state = state
        a.zip = zip
        a.country = country
        a.object_type = "address"
        a.save
        OutgoingMessage.delay.send_text_to_number_with_message_and_reason("+13343994374", "Somebody wants a gift!\n\nphone: #{a.phone}\nstreet: #{a.street}\nstreet_two: #{a.street_two}\ncity: #{a.city}\nstate: #{a.state}\nzip: #{a.zip}\ncountry: #{a.country}", "gift")
      else
        return nil
      end
    end
    return a
  end

end
