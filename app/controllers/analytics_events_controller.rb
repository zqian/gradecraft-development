#require_relative 'caliper_integration'

class AnalyticsEventsController < ApplicationController
  skip_before_filter :increment_page_views

  def predictor_event
    log_gradecraft_predict_grade_event(current_course, current_user, current_user.role(current_course), params[:assignment], params[:score], params[:possible] )
    Resque.enqueue(EventLogger, 'predictor',
                                course_id: current_course.id,
                                user_id: current_user.id,
                                student_id: current_student.try(:id),
                                user_role: current_user.role(current_course),
                                assignment_id: params[:assignment].to_i,
                                score: params[:score].to_i,
                                possible: params[:possible].to_i,
                                created_at: Time.now
                                )  
    # EventLogger.perform_async('predictor',
    #                             course_id: current_course.id,
    #                             user_id: current_user.id,
    #                             student_id: current_student.try(:id),
    #                             user_role: current_user.role(current_course),
    #                             assignment_id: params[:assignment].to_i,
    #                             score: params[:score].to_i,
    #                             possible: params[:possible].to_i,
    #                             created_at: Time.now
    #                          )
    render :nothing => true, :status => :ok
  end

  def tab_select_event
    Resque.enqueue(EventLogger, 'pageview',
                              course_id: current_course.id,
                              user_id: current_user.id,
                              student_id: current_student.try(:id),
                              user_role: current_user.role(current_course),
                              page: "#{params[:url]}#{params[:tab]}",
                              created_at: Time.now
                              )
    # EventLogger.perform_async('pageview',
    #                           course_id: current_course.id,
    #                           user_id: current_user.id,
    #                           student_id: current_student.try(:id),
    #                           user_role: current_user.role(current_course),
    #                           page: "#{params[:url]}#{params[:tab]}",
    #                           created_at: Time.now
    #                          )
    render :nothing => true, :status => :ok
  end
end
