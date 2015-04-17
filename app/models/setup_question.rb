class SetupQuestion < ActiveRecord::Base
  attr_accessible :percentage, :question

  scope :above_percentage, ->(p) { where("percentage > ?", p).order("percentage ASC") }
end
