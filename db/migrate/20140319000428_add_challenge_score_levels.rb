class AddChallengeScoreLevels < ActiveRecord::Migration
  def change
    create_table :challenge_score_levels do |t|
      t.integer :challenge_id
      t.string :name
      t.integer :value
 
      t.timestamps
    end
  end
end
