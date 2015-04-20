class SetupQuestion < ActiveRecord::Base
  attr_accessible :percentage, :question, :build_type

  # -- SCOPES
  scope :above_percentage, ->(p) { where("percentage > ?", p).order("percentage ASC") }


  # -- ACTIONS
  def self.create_from_question params
    if params[:setup_question] && params[:setup_question][:build_type] == "item"
      return Item.create_from_setup_question(params)
    elsif params[:setup_question] && params[:setup_question][:build_type] == "bucket"
      return Bucket.create_from_setup_question(params)
    end
  end
end
