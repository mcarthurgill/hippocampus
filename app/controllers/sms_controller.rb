class SmsController < ApplicationController


  # POST /sms
  # POST /sms.json
  def create

    @sm = Sm.new(params)

    
    if @sm.token_text?
      puts 'TOKEN ============================= '+token_for_verification_text(@sm.Body)
      # get or create user
      user = User.with_phone_number(@sm.From)
      user.delay.set_country_and_calling_codes_from_sm(@sm)
      # create token
      token = Token.create(token_string: token_for_verification_text(@sm.Body) , user_id: user.id, status: 'sms')
      # send web socket

      respond_to do |format|
        format.json { render json: @sm, status: :created }
      end


    elsif @sm.hippo_text?
      user = User.with_phone_number(@sm.From)
      user.delay.set_country_and_calling_codes_from_sm(@sm)

      respond_to do |format|
        format.json { render json: @sm, status: :created }
      end


    elsif @sm.ignore_text?
      respond_to do |format|
        format.json { render json: @sm, status: :created }
      end


    else
      @sm.add_media_if_present(params)
      respond_to do |format|
        if @sm.save
          @sm.should_send_follow_up_texts
          @sm.create_item
          format.json { render json: @sm, status: :created }
        else
          format.json { render json: @sm.errors, status: :unprocessable_entity }
        end
      end

    end

  end

end
