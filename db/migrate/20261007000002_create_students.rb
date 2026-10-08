class CreateStudents < ActiveRecord::Migration[8.1]
  def change
    create_table :students do |t|
      t.references :professor, null: false, foreign_key: true
      t.string :name, null: false
      t.string :email, null: false
      t.string :program, null: false, default: "Mestrado"
      t.string :research_area
      t.string :project_title
      t.text :research_problem
      t.text :objectives
      t.text :methodology
      t.boolean :active, null: false, default: true
      t.integer :progress, null: false, default: 0
      t.timestamps
    end

    add_index :students, [:professor_id, :email], unique: true
  end
end
