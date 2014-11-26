require 'application_responder'

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  #Canable details
  include Canable::Enforcers
  include Omniauth::Lti::Context
  include CustomNamedRoutes
  include CurrentScopes
  include CourseTerms
  delegate :can_view?, :to => :current_user
  helper_method :can_view?
  hide_action :can_view?

  respond_to :html

  protect_from_forgery with: :reset_session

  Rails.env.production? do
    before_filter :check_url
    force_ssl except: :ping
  end

  def check_url
    redirect_to request.protocol + "www." + request.host_with_port + request.fullpath if !/^www/.match(request.host)
  end

  before_filter :require_login, :except => [:not_authenticated]

  before_filter :increment_page_views

  before_filter :get_course_scores

  include ApplicationHelper

  def not_authenticated
    if request.env["REMOTE_USER"] != nil
      @user = User.find_by_username(request.env["REMOTE_USER"])
      if @user
        auto_login(@user)
        User.increment_counter(:visit_count, @user.id)
        redirect_to dashboard_path
      else
        redirect_to root_url, :alert => "Please login first."
        #We ultimately need to handle Cosign approved users who don't have GradeCraft accounts
      end
    else
      redirect_to root_path, :alert => "Please login first."
    end
  end

  # Getting the course scores to display the box plot results
  def get_course_scores
    if current_user.present? && current_user_is_student?
      @scores_for_current_course = current_student.scores_for_course(current_course)
    end
  end

  protected

  # Core role authentication
  def ensure_student?
    return not_authenticated unless current_user_is_student?
  end

  def ensure_staff?
    return not_authenticated unless current_user_is_staff?
  end

  def ensure_prof?
    return not_authenticated unless current_user_is_professor?
  end

  def ensure_admin?
    return not_authenticated unless current_user_is_admin?
  end

  private

  # Canable checks on permission
  def enforce_view_permission(resource)
    raise Canable::Transgression unless can_view?(resource)
  end

  # Tracking page view counts
  def increment_page_views
    if current_user && request.format.html?
      User.increment_counter(:page_views, current_user.id)
      EventLogger.perform_async('pageview', course_id: current_course.id, user_id: current_user.id, student_id: current_student.try(:id), user_role: current_user.role(current_course), page: request.original_fullpath, created_at: Time.now)
    end
  end

  # Tracking course logins
  def log_course_login_event
    membership = current_user.course_memberships.where(course_id: current_course.id).first
    EventLogger.perform_async('login', course_id: current_course.id, user_id: current_user.id, student_id: current_student.try(:id), user_role: current_user.role(current_course), last_login_at: membership.last_login_at.to_i, created_at: Time.now)
    membership.update_attribute(:last_login_at, Time.now)
  end

end
