class AddCreditToTiers < ActiveRecord::Migration
  def change
    change_table :tiers do |t|
      t.boolean :full_credit
      t.boolean :no_credit
    end
  end
end
