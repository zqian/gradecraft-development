class AddPassFailTermToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :pass_term, :string, limit: 255
    add_column :courses, :fail_term, :string, limit: 255
  end
end
