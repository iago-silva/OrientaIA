class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.references :orientation, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.date :due_on
      t.string :status, null: false, default: "pending"
      t.string :source, null: false, default: "web"
      t.datetime :completed_at
      t.timestamps
    end

    add_index :tasks, [:orientation_id, :status]
  end
end
