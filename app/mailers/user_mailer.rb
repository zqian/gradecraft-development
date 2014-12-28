class UserMailer < ActionMailer::Base
  default from: "admin@gradecraft.com"

  def reset_password_email(user)
    @user = user
    mail(:to => user.email, :subject => "Your password has been reset")
  end

  def welcome_student_email(user)
    @user = user
    mail(:to => user.email, :subject => "Welcome to GradeCraft")
  end

  def individual_badging_email(user, course)
    @user = user
    @user_first_name = user.first_name
    @date = Date.today.strftime("%A %B %d, %Y")
    @course_name = course.name
    @course_no = course.courseno
    @badge_term = course.badge_term
    @earned_badges_count = user.earned_badges.count
    @recently_earned_badges = user.recently_earned_badges
    @recently_earned_badges_count = user.recently_earned_badges_count
    @unearned_badges = user.unearned_badges_for_course(course)
    @congrats = ['Congrats!', 'Nice job!', 'Well done!', 'You rock!']
    if @user.avatar_file_name.present?
      @avatar = @user.avatar_file_name
    else
      @avatar = "http://localhost:5000/images/mo.png"
    end
    mail(to: user.email, :subject => "Your Weekly #{@badge_term} Update") do |format|
      format.html
      format.text
    end
  end

  def team_badging_email(user)
    @user = user
    mail(:to => user.email, :subject => "Your Weekly Badging Update")
  end

end
