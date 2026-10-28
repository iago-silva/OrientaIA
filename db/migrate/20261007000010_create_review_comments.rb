class CreateReviewComments < ActiveRecord::Migration[8.1]
  def change
    create_table :review_comments do |t|
      t.references :academic_work, null: false, foreign_key: true
      t.references :work_version, foreign_key: true
      t.string :section
      t.text :anchor_text
      t.text :content, null: false
      t.string :status, null: false, default: "open"
      t.string :author_name, null: false, default: "Orientadora"
      t.timestamps
    end
    add_index :review_comments, [ :academic_work_id, :status ]
  end
end
