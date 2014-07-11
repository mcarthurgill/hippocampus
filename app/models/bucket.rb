class Bucket < ActiveRecord::Base

  attr_accessible :description, :first_name, :last_name, :user_id, :bucket_type


  # -- RELATIONSHIPS

  belongs_to :user
  has_many :bucket_item_pairs
  has_many :items, :through => :bucket_item_pairs


  # -- SCOPES

  scope :above, ->(time) { where("updated_at > ?", Time.at(time.to_i).to_datetime).order('id ASC') }


  # -- VALIDATIONS

  before_validation :strip_whitespace

  def strip_whitespace
    self.description = self.description ? self.description.strip : nil
    self.first_name = self.first_name ? self.first_name.strip : nil
    self.last_name = self.last_name ? self.last_name.strip : nil
    self.bucket_type = self.bucket_type ? self.bucket_type.strip : nil
  end

end
