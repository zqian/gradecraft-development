class HomeController < ApplicationController

 before_filter :require_login, :only => [:login, :register]

  def index
    if current_user
      if current_course.use_timeline?
        redirect_to dashboard_path
      else
        if current_user.is_student?
          redirect_to syllabus_path
        else
          redirect_to analytics_top_10_path
        end
      end
    end
  end

end
