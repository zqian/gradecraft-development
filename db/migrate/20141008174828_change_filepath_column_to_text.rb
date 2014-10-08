class ChangeFilepathColumnToText < ActiveRecord::Migration
  def up
    change_column :submission_files, :filepath, :text
  end

  def down
    change_column :submission_files, :filepath, :string
  end
end
