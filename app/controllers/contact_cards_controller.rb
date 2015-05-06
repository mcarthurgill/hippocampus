class ContactCardsController < ApplicationController
  # POST /contact_cards
  # POST /contact_cards.json
  def create
    @contact_card = ContactCard.find_or_initialize_by_bucket_id_and_contact_info(params[:contact_card][:bucket_id], params[:contact_card][:contact_info])

    if params.has_key?(:file) && params[:file]
      @contact_card.upload_main_asset(params[:file])
    end

    respond_to do |format|
      if @contact_card.save
        format.html { redirect_to @contact_card, notice: 'Contact card was successfully created.' }
        format.json { render json: @contact_card }
      else
        format.html { render action: "new" }
        format.json { render json: @contact_card.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @contact_card = ContactCard.find(params[:id])

    respond_to do |format|
      if @contact_card.destroy
        format.json { head :no_content }
      else
        format.json { render json: @contact_card.errors, status: :unprocessable_entity }
      end
    end
  end
end
