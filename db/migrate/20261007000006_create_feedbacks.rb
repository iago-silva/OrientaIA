class CreateFeedbacks < ActiveRecord::Migration[8.1]
  def change
    create_table :feedbacks do |t|
      t.references :orientation, null: false, foreign_key: true
      t.string :author_name, null: false
      t.text :content, null: false
      t.string :source, null: false, default: "web"
      t.timestamps
    end
  end
end
