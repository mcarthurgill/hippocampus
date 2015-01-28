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
        render :js => "window.location.href='"+fail_path+"'", :notice => "Sorry Hippocampus just isn't for you."
        return
      else
        render :js => "window.location.href='"+login_path+"'", :notice => "We built Hippocampus for you."
        return
      end      
    end

    @question = IntroductionQuestion.find(@qids[index + 1])

    respond_to do |format|
      format.js
    end
  end

  def fail
  end
end
