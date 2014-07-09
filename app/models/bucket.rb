class Bucket < ActiveRecord::Base

  attr_accessible :description, :first_name, :last_name, :user_id, :bucket_type


  # -- RELATIONSHIPS

  belongs_to :user
  has_many :bucket_item_pairs
  has_many :items, :through => :bucket_item_pairs


  # -- SCOPES

  scope :above, ->(time) { where("updated_at > ?", Time.at(time.to_i).to_datetime) }

end
