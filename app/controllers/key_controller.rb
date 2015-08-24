class KeyController < ApplicationController

  def detail
    
    user = User.find_by_id(params[:auth][:uid])

    object = {}

    if params[:object_type] == 'bucket'
      object = Bucket.find_by_local_key(params[:local_key])
    elsif params[:object_type] == 'item'
      object = Item.find_by_local_key(params[:local_key])
    end

    respond_to do |format|
      if user
        format.json { render json: object }
      else
        format.json { render status: :unprocessable_entity }
      end
    end

  end

end
