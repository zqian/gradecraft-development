class RubricsController < ApplicationController
  before_action :find_rubric, except: [:design, :create]

  respond_to :html, :json

  def design
    @assignment = Assignment.find params[:assignment_id]
    @rubric = Rubric.find_or_create_by(assignment_id: @assignment.id)
    @metrics = existing_metrics_as_json
    @course_badges = serialized_course_badges
    respond_with @rubric
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

  def existing_metrics_as_json
    ActiveModel::ArraySerializer.new(rubric_metrics_with_tiers, each_serializer: ExistingMetricSerializer).to_json
  end

  def serialized_course_badges
    ActiveModel::ArraySerializer.new(course_badges, each_serializer: CourseBadgeSerializer).to_json
  end

  def course_badges
    @course_badges ||= @assignment.course.badges.visible
  end

  def rubric_metrics_with_tiers
    @rubric.metrics.order(:order).includes(:tiers)
  end

  def find_rubric
    @rubric = Rubric.find params[:id]
  end
end
