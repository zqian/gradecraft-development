module CourseTerms
  def self.included(base)
    base.helper_method :term_for if base < ActionController::Base
  end

  def term_for(key, fallback = nil)
    case key.downcase.to_sym
    when :student then current_course.user_term.to_s.singularize
    when :weight, :assignment, :badge, :team, :team_leader, :group
      # TODO: downcase in forms, not in titles
      current_course.send("#{key}_term").to_s.singularize.downcase
    when :pass, :fail
      current_course.send("#{key.downcase}_term").to_s
    when :challenge then "#{term_for(:team)} #{current_course.challenge_term}"
    when :assignment_type then "#{term_for(:assignment)} Type"
    when :students, :weights, :assignments, :assignment_types, :teams, :team_leaders, :badges, :challenges, :groups
      term_for(key.to_s.downcase.singularize).pluralize
    else
      fallback.presence || raise("No term defined for :#{key} Please define one in lib/course_terms.rb.")
    end
  end
end
