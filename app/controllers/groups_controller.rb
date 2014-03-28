class GroupsController < ApplicationController
  before_filter :ensure_staff?, :only => :index

  def index
    @groups = current_course.groups
    @assignments = current_course.assignments.group_assignments
    @title = current_course.group_term.pluralize
  end

  def show
    if current_user.is_student?
      @user = current_user
    end
    @group = current_course.groups.find(params[:id])
    @assignments = current_course.assignments.group_assignments
  end

  def new
    @group = current_course.groups.new
    @group_students << current_user if current_user.is_student?
    @assignments = current_course.assignments.group_assignments
    @title = "Start a #{term_for :group}"
  end

  def review
    @group = current_course.groups.find(params[:id])
    @title = "Reviewing #{@group.name}"
  end

  def create
    @group = current_course.groups.new(params[:group])
    @assignments = current_course.assignments.group_assignments
    @group.students << current_user if current_user.is_student?
    respond_to do |format|
      if @group.save
        NotificationMailer.group_created(@group.id).deliver
        NotificationMailer.group_notify(@group.id).deliver
        format.html { respond_with @group }
      else
        @title = "Start a #{term_for :group}"
        format.html { render action: "new" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @group = current_course.groups.find(params[:id])
    @assignments = current_course.assignments.group_assignments
    @title = "Editing #{@group.name} Details"
  end

  def update
    @group = current_course.groups.find(params[:id])
    @group.update_attributes(params[:group])
    respond_to do |format|
      if @group.approved.present?
        NotificationMailer.group_status_updated(@group.id).deliver
        format.html { respond_with @group }
      end
    end
  end

  def destroy
    @group = current_course.groups.find(params[:id])
    @group.destroy
    respond_with @group
  end
end
