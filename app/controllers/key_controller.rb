class KeyController < ApplicationController

  def detail
    
    user = User.find_by_id(params[:auth][:uid])

    object = {}

    if params[:object_type] == 'bucket'
      object = Bucket.find_by_local_key(params[:local_key])
    elsif params[:object_type] == 'item'
      object = Item.includes(:user).find_by_local_key(params[:local_key])
    end

    respond_to do |format|
      if user
        format.json do
          render json: object.as_json(methods: [:user, :user_ids_array]) if object.object_type == 'item'
          render json: object if object.object_type == 'bucket'
        end
      else
        format.json { render status: :unprocessable_entity }
      end
    end

  end

end
