# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_25_000002) do
  create_table "abnt_checks", force: :cascade do |t|
    t.integer "academic_work_id", null: false
    t.integer "work_version_id"
    t.string "code", null: false
    t.string "category", null: false
    t.string "severity", default: "suggestion", null: false
    t.string "title", null: false
    t.text "excerpt"
    t.text "recommendation"
    t.string "status", default: "suggestion", null: false
    t.datetime "checked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "page_number"
    t.string "section"
    t.datetime "human_checked_at"
    t.index ["academic_work_id", "code"], name: "index_abnt_checks_on_academic_work_id_and_code", unique: true
    t.index ["academic_work_id"], name: "index_abnt_checks_on_academic_work_id"
    t.index ["work_version_id"], name: "index_abnt_checks_on_work_version_id"
  end

  create_table "academic_works", force: :cascade do |t|
    t.integer "student_id", null: false
    t.string "title", null: false
    t.string "category", default: "Capítulo", null: false
    t.string "status", default: "draft", null: false
    t.integer "current_version", default: 1, null: false
    t.text "manuscript"
    t.datetime "submitted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id", "title"], name: "index_academic_works_on_student_id_and_title", unique: true
    t.index ["student_id"], name: "index_academic_works_on_student_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "audit_events", force: :cascade do |t|
    t.integer "review_record_id", null: false
    t.string "actor", null: false
    t.string "action", null: false
    t.integer "revision", null: false
    t.json "details", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["review_record_id"], name: "index_audit_events_on_review_record_id"
  end

  create_table "consent_events", force: :cascade do |t|
    t.integer "consent_id", null: false
    t.string "action", null: false
    t.string "actor", null: false
    t.text "scope"
    t.string "term_version", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["consent_id"], name: "index_consent_events_on_consent_id"
  end

  create_table "consents", force: :cascade do |t|
    t.integer "orientation_id", null: false
    t.integer "meeting_id"
    t.string "participant_type", null: false
    t.integer "participant_id", null: false
    t.string "purpose", null: false
    t.string "term_version", default: "1.0", null: false
    t.boolean "granted", default: false, null: false
    t.text "scope"
    t.datetime "accepted_at"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meeting_id"], name: "index_consents_on_meeting_id"
    t.index ["orientation_id", "participant_type", "participant_id", "purpose", "meeting_id"], name: "index_consents_on_participant_and_scope", unique: true
    t.index ["orientation_id"], name: "index_consents_on_orientation_id"
    t.index ["participant_type", "participant_id"], name: "index_consents_on_participant"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.integer "orientation_id", null: false
    t.string "author_name", null: false
    t.text "content", null: false
    t.string "source", default: "web", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["orientation_id"], name: "index_feedbacks_on_orientation_id"
  end

  create_table "meetings", force: :cascade do |t|
    t.integer "orientation_id", null: false
    t.datetime "held_at", null: false
    t.string "title", null: false
    t.text "transcript"
    t.text "summary"
    t.text "next_steps"
    t.string "source", default: "web", null: false
    t.string "external_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["orientation_id", "external_id"], name: "index_meetings_on_orientation_id_and_external_id", unique: true
    t.index ["orientation_id"], name: "index_meetings_on_orientation_id"
  end

  create_table "opportunity_recommendations", force: :cascade do |t|
    t.integer "student_id", null: false
    t.string "title", null: false
    t.string "item_type", default: "event", null: false
    t.string "organization"
    t.string "subject"
    t.date "event_on"
    t.date "deadline_on"
    t.text "description"
    t.text "reason"
    t.integer "relevance", default: 80, null: false
    t.string "status", default: "recommended", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "recommended_by"
    t.text "message"
    t.date "preparation_on"
    t.datetime "acknowledged_at"
    t.string "website"
    t.index ["student_id", "title"], name: "index_opportunity_recommendations_on_student_id_and_title", unique: true
    t.index ["student_id"], name: "index_opportunity_recommendations_on_student_id"
  end

  create_table "orientation_messages", force: :cascade do |t|
    t.integer "orientation_id", null: false
    t.string "author_name", null: false
    t.string "author_role", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["orientation_id"], name: "index_orientation_messages_on_orientation_id"
  end

  create_table "orientations", force: :cascade do |t|
    t.integer "professor_id", null: false
    t.integer "student_id", null: false
    t.string "title", null: false
    t.string "status", default: "active", null: false
    t.datetime "next_meeting_at"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["professor_id", "student_id"], name: "index_orientations_on_professor_id_and_student_id", unique: true
    t.index ["professor_id"], name: "index_orientations_on_professor_id"
    t.index ["student_id"], name: "index_orientations_on_student_id"
  end

  create_table "processing_requests", force: :cascade do |t|
    t.integer "orientation_id", null: false
    t.integer "review_record_id"
    t.integer "work_version_id"
    t.string "status", default: "pending", null: false
    t.string "requested_by", null: false
    t.string "destination", default: "local", null: false
    t.text "instructions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["orientation_id"], name: "index_processing_requests_on_orientation_id"
    t.index ["review_record_id"], name: "index_processing_requests_on_review_record_id"
    t.index ["work_version_id"], name: "index_processing_requests_on_work_version_id"
  end

  create_table "professors", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "institution"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_professors_on_email", unique: true
  end

  create_table "review_comments", force: :cascade do |t|
    t.integer "academic_work_id", null: false
    t.integer "work_version_id"
    t.string "section"
    t.text "anchor_text"
    t.text "content", null: false
    t.string "status", default: "open", null: false
    t.string "author_name", default: "Orientadora", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "published_at"
    t.index ["academic_work_id", "status"], name: "index_review_comments_on_academic_work_id_and_status"
    t.index ["academic_work_id"], name: "index_review_comments_on_academic_work_id"
    t.index ["work_version_id"], name: "index_review_comments_on_work_version_id"
  end

  create_table "review_records", force: :cascade do |t|
    t.integer "orientation_id", null: false
    t.integer "meeting_id"
    t.integer "work_version_id"
    t.integer "feedback_id"
    t.string "title", null: false
    t.string "kind", default: "meeting", null: false
    t.string "status", default: "pending", null: false
    t.integer "revision", default: 1, null: false
    t.json "original_content", default: {}, null: false
    t.json "edited_content", default: {}, null: false
    t.json "published_content", default: {}, null: false
    t.text "evidence"
    t.text "justification"
    t.boolean "source_checked", default: false, null: false
    t.boolean "acknowledged_limits", default: false, null: false
    t.json "included_items", default: [], null: false
    t.datetime "published_at"
    t.string "published_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feedback_id"], name: "index_review_records_on_feedback_id", unique: true
    t.index ["meeting_id"], name: "index_review_records_on_meeting_id", unique: true
    t.index ["orientation_id"], name: "index_review_records_on_orientation_id"
    t.index ["work_version_id"], name: "index_review_records_on_work_version_id", unique: true
  end

  create_table "students", force: :cascade do |t|
    t.integer "professor_id", null: false
    t.string "name", null: false
    t.string "email", null: false
    t.string "program", default: "Mestrado", null: false
    t.string "research_area"
    t.string "project_title"
    t.text "research_problem"
    t.text "objectives"
    t.text "methodology"
    t.boolean "active", default: true, null: false
    t.integer "progress", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.integer "training_step", default: 0, null: false
    t.datetime "training_completed_at"
    t.index ["professor_id", "email"], name: "index_students_on_professor_id_and_email", unique: true
    t.index ["professor_id"], name: "index_students_on_professor_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.integer "orientation_id", null: false
    t.string "title", null: false
    t.text "description"
    t.date "due_on"
    t.string "status", default: "pending", null: false
    t.string "source", default: "web", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["orientation_id", "status"], name: "index_tasks_on_orientation_id_and_status"
    t.index ["orientation_id"], name: "index_tasks_on_orientation_id"
  end

  create_table "work_versions", force: :cascade do |t|
    t.integer "academic_work_id", null: false
    t.integer "version_number", null: false
    t.string "label"
    t.text "change_note"
    t.string "status", default: "received", null: false
    t.string "uploaded_by", default: "student", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sensitivity", default: "low", null: false
    t.string "processing_destination", default: "local", null: false
    t.string "analysis_state", default: "not_started", null: false
    t.index ["academic_work_id", "version_number"], name: "index_work_versions_on_academic_work_id_and_version_number", unique: true
    t.index ["academic_work_id"], name: "index_work_versions_on_academic_work_id"
  end

  add_foreign_key "abnt_checks", "academic_works"
  add_foreign_key "abnt_checks", "work_versions"
  add_foreign_key "academic_works", "students"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "audit_events", "review_records"
  add_foreign_key "consent_events", "consents"
  add_foreign_key "consents", "meetings"
  add_foreign_key "consents", "orientations"
  add_foreign_key "feedbacks", "orientations"
  add_foreign_key "meetings", "orientations"
  add_foreign_key "opportunity_recommendations", "students"
  add_foreign_key "orientation_messages", "orientations"
  add_foreign_key "orientations", "professors"
  add_foreign_key "orientations", "students"
  add_foreign_key "processing_requests", "orientations"
  add_foreign_key "processing_requests", "review_records"
  add_foreign_key "processing_requests", "work_versions"
  add_foreign_key "review_comments", "academic_works"
  add_foreign_key "review_comments", "work_versions"
  add_foreign_key "review_records", "feedbacks"
  add_foreign_key "review_records", "meetings"
  add_foreign_key "review_records", "orientations"
  add_foreign_key "review_records", "work_versions"
  add_foreign_key "students", "professors"
  add_foreign_key "tasks", "orientations"
  add_foreign_key "work_versions", "academic_works"
end
