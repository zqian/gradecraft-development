class CreateProposals < ActiveRecord::Migration
  def change
    create_table :proposals do |t|
      t.string :title
      t.text :proposal
      t.integer :group_id
      t.text :feedback
      t.boolean :approved
      t.integer :submitted_by

      t.timestamps
    end
  end
end
