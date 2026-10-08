class CreateAbntChecks < ActiveRecord::Migration[8.1]
  def change
    create_table :abnt_checks do |t|
      t.references :academic_work, null: false, foreign_key: true
      t.references :work_version, foreign_key: true
      t.string :code, null: false
      t.string :category, null: false
      t.string :severity, null: false, default: "suggestion"
      t.string :title, null: false
      t.text :excerpt
      t.text :recommendation
      t.string :status, null: false, default: "suggestion"
      t.datetime :checked_at
      t.timestamps
    end
    add_index :abnt_checks, [:academic_work_id, :code], unique: true
  end
end
