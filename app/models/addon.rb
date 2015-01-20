 class Addon < ActiveRecord::Base
  attr_accessible :addon_name, :addon_url

  # --- ASSOCIATIONS
  has_many :tokens

  # --- SCOPES
  scope :daily_j, -> { where("addon_name = ?", "daily_j") }

  # --- CALLBACKS
  after_create :create_api_token

  def create_api_token
    t = Token.with_params(:addon_id => self.id)
    t.assign_token
    t.save
  end


  # --- QUERY
  def self.for_addon_name_and_token(name, token)
    addon = Addon.where("addon_name = ?", name).first
    if addon
      t = Token.for_addon(addon.id).live.first
      if t.token_string == token
        return addon
      end
    end
    return nil
  end

  # --- HTTP
  def self.create_user_for_addon(user, addon, bucket)
    response = HTTParty.post(addon.create_user_url, :query => { 
                      :user => { :hippocampus_user_id => user.id, :token => Token.for_user_and_addon(user.id, addon.id).first.token_string, :bucket_id => bucket.id },
                      :addon => "hippocampus",
                      :addon_token => Token.for_addon(addon.id).live.first.token_string
                  })

    return response.code == 200
  end

  def determine_endpoint_action(params)
    if self.daily_j?
      case params[:request_type]
      when "create_item"
        i = Item.create_from_api_endpoint(params) 
        return i ? i.bucket_id : nil
      when "get_items"
        u = User.validated_with_id_addon_and_token(params[:user][:hippocampus_user_id], self, params[:user][:token]) 
        return u ? u.items_for_addon(self) : nil
      when "update_item"
        u = User.validated_with_id_addon_and_token(params[:user][:hippocampus_user_id], self, params[:user][:token]) 
        i = Item.find(params[:item][:id])
        return i.update_attributes(:message => params[:item][:message]) ? i : nil
      end
    end
  end

  # --- HELPERS
  def create_user_url
    self.addon_url + "/users.json"
  end

  def params_to_create_bucket_for_user(user, first_name=true)
    if self.daily_j?
      if first_name
        return {:first_name => "Daily Journal", :bucket_type => "Journal", :user_id => user.id}
      else
        return {:bucket_type => "Journal", :user_id => user.id}
      end
    end
  end

  def daily_j?
    self == Addon.daily_j.first
  end
end
