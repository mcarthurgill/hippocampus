class SetupQuestionsController < ApplicationController

  def get_questions
    setup_questions = SetupQuestion.above_percentage(params[:percentage])

    respond_to do |format|
      format.json { render json: {:questions => setup_questions } }
    end
  end

  def create_from_question
    resp = SetupQuestion.create_from_question(params)

    u = User.find(params[:auth][:uid])
    u.update_with_params(params[:setup_question][:question])

    respond_to do |format|
      format.json { render json: { :response => resp, :setup_completion => u.setup_completion } }
    end
  end  
end
