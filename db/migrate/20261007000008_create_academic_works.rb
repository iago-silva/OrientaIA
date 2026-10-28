class CreateAcademicWorks < ActiveRecord::Migration[8.1]
  def change
    create_table :academic_works do |t|
      t.references :student, null: false, foreign_key: true
      t.string :title, null: false
      t.string :category, null: false, default: "Capítulo"
      t.string :status, null: false, default: "draft"
      t.integer :current_version, null: false, default: 1
      t.text :manuscript
      t.datetime :submitted_at
      t.timestamps
    end
    add_index :academic_works, [ :student_id, :title ], unique: true
  end
end
