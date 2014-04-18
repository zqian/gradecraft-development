class AddFullCreditTierIdToMetric < ActiveRecord::Migration
  def change
    add_column :metrics, :full_credit_tier_id, :integer
  end
end
