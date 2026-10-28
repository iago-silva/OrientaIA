class CreateOrientations < ActiveRecord::Migration[8.1]
  def change
    create_table :orientations do |t|
      t.references :professor, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true
      t.string :title, null: false
      t.string :status, null: false, default: "active"
      t.datetime :next_meeting_at
      t.text :notes
      t.timestamps
    end

    add_index :orientations, [ :professor_id, :student_id ], unique: true
  end
end
