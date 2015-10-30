class BucketTagPair < ActiveRecord::Base
  attr_accessible :bucket_id, :tag_id

  belongs_to :bucket
  belongs_to :tag

  after_create :update_underlying_objects
  after_destroy :update_underlying_objects

  def update_underlying_objects
  end

end
