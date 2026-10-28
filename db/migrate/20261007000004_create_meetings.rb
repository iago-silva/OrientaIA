class CreateMeetings < ActiveRecord::Migration[8.1]
  def change
    create_table :meetings do |t|
      t.references :orientation, null: false, foreign_key: true
      t.datetime :held_at, null: false
      t.string :title, null: false
      t.text :transcript
      t.text :summary
      t.text :next_steps
      t.string :source, null: false, default: "web"
      t.string :external_id
      t.timestamps
    end

    add_index :meetings, [ :orientation_id, :external_id ], unique: true
  end
end
