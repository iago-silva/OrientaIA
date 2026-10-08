class CreateWorkVersions < ActiveRecord::Migration[8.1]
  def change
    create_table :work_versions do |t|
      t.references :academic_work, null: false, foreign_key: true
      t.integer :version_number, null: false
      t.string :label
      t.text :change_note
      t.string :status, null: false, default: "received"
      t.string :uploaded_by, null: false, default: "student"
      t.timestamps
    end
    add_index :work_versions, [:academic_work_id, :version_number], unique: true
  end
end
