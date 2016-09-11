class Admin::QuestionsController < ApplicationController
  before_filter :require_admin_user
  layout "admin"

  def index
    @questions = Question.paginate :page => params[:page], :per_page => 20
  end

  def show
    @question = Question.find(params[:id])
  end

  def new
    @question = Question.new
  end

  def edit
    @question = Question.find(params[:id])
  end

  def create
    @question = Question.new(params[:question])

    if @question.save
      redirect_to(new_admin_question_url, :notice => 'Question was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @question = Question.find(params[:id])

    if @question.update_attributes(params[:question])
      redirect_to(admin_question_url(@question), :notice => 'Question was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @question = Question.find(params[:id])
    @question.destroy

    redirect_to(admin_questions_url)
  end
end
