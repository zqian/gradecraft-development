class UserMailer < ActionMailer::Base
  default from: "cholma@umich.edu"

  def reset_password_email(user)
    @user = user
    mail(:to => user.email, :subject => "Your password has been reset")
  end

  def welcome_student_email(user)

  end

  def individual_badging_email(user)

  end

  def team_badging_email(user)

  end

end
