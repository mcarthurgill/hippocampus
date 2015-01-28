class IntroductionsController < ApplicationController
  def show
    redirect_logged_in_user
    @questions = IntroductionQuestion.live_with_responses
    @qids = @questions.pluck(:id)
    @flagged = 0
  end

  def next
    @qids = params[:qids]
    @flagged = params[:flagged].to_i
    index = @qids.index(params[:qid])

    if index == @qids.length - 1
      if @flagged/2.0 > (@qids.length - 1)/2.0
        redirect_to fail_path(:format => "html"), :notice => "Sorry. Hippocampus just isn't for you." 
        return
      else
        redirect_to login_path(:format => "html"), :notice => "Hippocampus is perfect for you. Let's do this." 
        return
      end      
    end

    @question = IntroductionQuestion.find(@qids[index + 1])

    respond_to do |format|
      format.js
    end
  end

  def fail
    p "*"*50
  end
end
