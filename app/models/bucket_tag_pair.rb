class BucketTagPair < ActiveRecord::Base
  attr_accessible :bucket_id, :tag_id

  belongs_to :bucket
  belongs_to :tag
end
