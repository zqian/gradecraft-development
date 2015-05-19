class AddSyllabusUpload < ActiveRecord::Migration
  def change
    add_column :courses, :syllabus, :string
  end
end
