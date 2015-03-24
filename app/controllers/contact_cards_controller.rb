class ContactCardsController < ApplicationController
  # POST /contact_cards
  # POST /contact_cards.json
  def create
    @contact_card = ContactCard.new(params[:contact_card])

    respond_to do |format|
      if @contact_card.save
        format.html { redirect_to @contact_card, notice: 'Contact card was successfully created.' }
        format.json { render json: @contact_card, status: :created, location: @contact_card }
      else
        format.html { render action: "new" }
        format.json { render json: @contact_card.errors, status: :unprocessable_entity }
      end
    end
  end
end
