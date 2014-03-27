class ChangeProposalToFeedback < ActiveRecord::Migration
  def change
    rename_column :groups, :proposal, :text_feedback
  end
end
