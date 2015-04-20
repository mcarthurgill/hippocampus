class SetupQuestionsController < ApplicationController

  def get_questions
    setup_questions = SetupQuestion.above_percentage(params[:percentage])

    respond_to do |format|
      format.json { render json: {:questions => setup_questions } }
    end
  end

  def create_from_question
    resp = SetupQuestion.create_from_question(params)

    respond_to do |format|
      format.json { render json: { :response => resp } }
    end
  end  
end
