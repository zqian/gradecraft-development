class AddTimestampsToFileUploads < ActiveRecord::Migration
  def change
    [:assignment_files, :badge_files, :challenge_files, :grade_files, :submission_files].each do |table|
      change_table table do |t|
        t.timestamps
      end
    end
  end
end
