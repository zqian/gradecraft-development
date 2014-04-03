class RubricsController < ApplicationController
  before_action :find_rubric, except: [:design, :create]

  respond_to :html, :json

  def design
    @assignment = Assignment.find params[:assignment_id]
    @rubric = Rubric.find_or_create_by(assignment_id: @assignment.id)
    respond_with @rubric
  end

  def metrics
    respond_to do |format|
      format.json do
        render json: @rubric.metrics.includes(:tiers)
      end
    end
  end

  def edit
    respond_with @rubric
  end

  def create
    @rubric = Rubric.create params[:rubric]
    respond_with @rubric
  end

  def destroy
    @rubric.destroy
    respond_with @rubric
  end

  def show
    respond_with @rubric
  end

  def update
    @rubric.update_attributes params[:rubric]
    respond_with @rubric, status: :not_found
  end

  private
  def find_rubric
    @rubric = Rubric.find params[:id]
  end
end
