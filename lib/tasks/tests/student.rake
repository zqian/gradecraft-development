namespace :student do
  namespace :test do
    desc "Check which student visible earned badges are found"
    task :student_visible_earned_badges => :environment do
      earned_badges = @u.student_visible_earned_badges(@c)
      puts "Found #{earned_badges.count} visible earned badges for that student."
      pp earned_badges if ARGV.last == "verbose"
   end

    desc "Check which unique badges are associated with student visible earned badges"
    task :unique_student_earned_badges => :environment do
      badges = @u.unique_student_earned_badges(@c)
      puts "Found #{badges.count} unique badges."
      pp badges if ARGV.last == "verbose"
    end

    desc "Check which unique badges are associated with student visible earned badges"
    task :student_visible_unearned_badges => :environment do
      earned_badges = @u.student_visible_unearned_badges
      puts "Found #{earned_badges.count} visible unearned badges for that student."
      pp badges if ARGV.last == "verbose"
    end
  end

  before :student_visible_earned_badges, :unique_student_earned_badges, :student_visible_earned_badges do
    @c = Course.find 7
    @u = User.find 706
  end
end
