class BucketTagPair < ActiveRecord::Base
  attr_accessible :bucket_id, :tag_id

  belongs_to :bucket
  belongs_to :tag

  after_destroy :update_underlying_objects

  def update_underlying_objects
    self.bucket.delay.update_tags_array if self.bucket
  end

end
