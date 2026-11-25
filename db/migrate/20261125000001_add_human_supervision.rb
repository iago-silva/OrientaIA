class AddHumanSupervision < ActiveRecord::Migration[8.1]
  def change
    add_column :students, :training_step, :integer, default: 0, null: false
    add_column :students, :training_completed_at, :datetime
    add_column :work_versions, :sensitivity, :string, default: "low", null: false
    add_column :work_versions, :processing_destination, :string, default: "local", null: false
    add_column :work_versions, :analysis_state, :string, default: "not_started", null: false
    add_column :review_comments, :published_at, :datetime
    add_column :abnt_checks, :page_number, :integer
    add_column :abnt_checks, :section, :string
    add_column :abnt_checks, :human_checked_at, :datetime
    add_column :opportunity_recommendations, :recommended_by, :string
    add_column :opportunity_recommendations, :message, :text
    add_column :opportunity_recommendations, :preparation_on, :date
    add_column :opportunity_recommendations, :acknowledged_at, :datetime
    add_column :opportunity_recommendations, :website, :string

    create_table :review_records do |t|
      t.references :orientation, null: false, foreign_key: true
      t.references :meeting, foreign_key: true, index: { unique: true }
      t.references :work_version, foreign_key: true, index: { unique: true }
      t.references :feedback, foreign_key: true, index: { unique: true }
      t.string :title, null: false
      t.string :kind, default: "meeting", null: false
      t.string :status, default: "pending", null: false
      t.integer :revision, default: 1, null: false
      t.json :original_content, default: {}, null: false
      t.json :edited_content, default: {}, null: false
      t.json :published_content, default: {}, null: false
      t.text :evidence
      t.text :justification
      t.boolean :source_checked, default: false, null: false
      t.boolean :acknowledged_limits, default: false, null: false
      t.json :included_items, default: [], null: false
      t.datetime :published_at
      t.string :published_by
      t.timestamps
    end

    create_table :audit_events do |t|
      t.references :review_record, null: false, foreign_key: true
      t.string :actor, null: false
      t.string :action, null: false
      t.integer :revision, null: false
      t.json :details, default: {}, null: false
      t.timestamps
    end

    create_table :consents do |t|
      t.references :orientation, null: false, foreign_key: true
      t.references :meeting, foreign_key: true
      t.references :participant, polymorphic: true, null: false
      t.string :purpose, null: false
      t.string :term_version, default: "1.0", null: false
      t.boolean :granted, default: false, null: false
      t.text :scope
      t.datetime :accepted_at
      t.datetime :revoked_at
      t.timestamps
      t.index [ :orientation_id, :participant_type, :participant_id, :purpose, :meeting_id ], name: "index_consents_on_participant_and_scope", unique: true
    end

    create_table :processing_requests do |t|
      t.references :orientation, null: false, foreign_key: true
      t.references :review_record, foreign_key: true
      t.references :work_version, foreign_key: true
      t.string :status, default: "pending", null: false
      t.string :requested_by, null: false
      t.string :destination, default: "local", null: false
      t.text :instructions
      t.timestamps
    end

    create_table :orientation_messages do |t|
      t.references :orientation, null: false, foreign_key: true
      t.string :author_name, null: false
      t.string :author_role, null: false
      t.text :content, null: false
      t.timestamps
    end
  end
end
