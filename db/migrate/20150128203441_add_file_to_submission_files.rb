class AddFileToSubmissionFiles < ActiveRecord::Migration
  def change
    add_column :submission_files, :file, :string
  end
end
