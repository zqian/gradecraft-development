class AddProcessingFieldToFileUploads < ActiveRecord::Migration
  def change
    add_column :submission_files, :file_processing, :boolean, null: false, default: false
  end
end
