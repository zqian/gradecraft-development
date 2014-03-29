class ChangeTextProposalToText < ActiveRecord::Migration
  def change
    change_column :groups, :text_feedback, :text
  end
end
