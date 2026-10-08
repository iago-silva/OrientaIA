class CreateOpportunityRecommendations < ActiveRecord::Migration[8.1]
  def change
    create_table :opportunity_recommendations do |t|
      t.references :student, null: false, foreign_key: true
      t.string :title, null: false
      t.string :item_type, null: false, default: "event"
      t.string :organization
      t.string :subject
      t.date :event_on
      t.date :deadline_on
      t.text :description
      t.text :reason
      t.integer :relevance, null: false, default: 80
      t.string :status, null: false, default: "recommended"
      t.timestamps
    end
    add_index :opportunity_recommendations, [:student_id, :title], unique: true
  end
end
