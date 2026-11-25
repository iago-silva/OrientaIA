require "test_helper"
require_relative "../support/portal_data"

class StudentActionsTest < ActionDispatch::IntegrationTest
  include PortalData
  setup { build_portal; sign_in(@student) }

  test "formation cannot be skipped by direct URL or forged completion" do
    @student.update!(training_completed_at: nil, training_step: 0)
    get academic_works_path
    assert_redirected_to training_path
    patch training_path, params: { step: 2, commitment: "1" }
    assert_nil @student.reload.training_completed_at
    patch training_path, params: { step: 0 }
    assert_equal 1, @student.reload.training_step
    patch training_path, params: { step: 1, answer: "invent" }
    assert_equal 1, @student.reload.training_step
    patch training_path, params: { step: 1, answer: "verify" }
    assert_equal 2, @student.reload.training_step
    patch training_path, params: { step: 2 }
    assert_nil @student.reload.training_completed_at
    patch training_path, params: { step: 2, commitment: "1" }
    assert @student.reload.trained?
    get root_path
    assert_response :success
  end

  test "consent changes only the current participant and retains a history" do
    params = { orientation_id: @orientation.id, meeting_id: @meeting.id, purpose: "recording", participant_id: @professor.id, participant_type: "Professor" }
    post consents_path, params: params.merge(decision: "grant")
    consent = Consent.last
    assert_equal @student, consent.participant
    assert consent.active?
    assert_equal 1, consent.consent_events.count
    post consents_path, params: params.merge(decision: "revoke")
    assert_not consent.reload.active?
    assert_equal 2, consent.consent_events.count
    assert_equal "pending", @record.reload.status
    get privacy_path
    assert_response :success
  end

  test "external consent and external processing cannot be forced" do
    assert_no_difference "Consent.count" do
      post consents_path, params: { orientation_id: @orientation.id, meeting_id: @meeting.id, purpose: "external", decision: "grant" }
    end
    assert_no_difference "WorkVersion.count" do
      post academic_work_work_versions_path(@work), params: { work_version: { file: pdf_upload, sensitivity: "sensitive", processing_destination: "external" } }
    end
  end

  test "upload preserves previous versions and PDF can be downloaded" do
    assert_difference "WorkVersion.count", 1 do
      post academic_work_work_versions_path(@work), params: { work_version: { file: pdf_upload, change_note: "Revisão ampliada", sensitivity: "sensitive", processing_destination: "local" } }
    end
    new_version = @work.work_versions.first
    assert_equal 2, new_version.version_number
    assert_equal "received", new_version.status
    assert_equal "approved", @version.reload.status
    assert new_version.file.attached?
    get download_version_path(@work, new_version)
    assert_response :success
    assert response.body.start_with?("%PDF")
    post processing_requests_path, params: { work_version_id: new_version.id }
    assert_equal "blocked", new_version.processing_requests.last.status
  end

  test "missing invalid and oversized files are rejected" do
    bad = Rack::Test::UploadedFile.new(StringIO.new("not a PDF"), "text/plain", original_filename: "bad.txt")
    huge = Rack::Test::UploadedFile.new(StringIO.new("%PDF" + "a" * 25.megabytes), "application/pdf", original_filename: "huge.pdf")
    [ nil, bad, huge ].each do |file|
      assert_no_difference "WorkVersion.count" do
        post academic_work_work_versions_path(@work), params: { work_version: { file: file, sensitivity: "low", processing_destination: "local" } }
      end
      assert_response :redirect
    end
  end

  test "documents comments tasks ABNT and human messages have persistent actions" do
    assert_difference "AcademicWork.count", 1 do
      post academic_works_path, params: { academic_work: { title: "Artigo novo", category: "Artigo" } }
    end
    patch academic_work_review_comment_path(@work, @comment)
    assert_equal "resolved", @comment.reload.status
    patch academic_work_review_comment_path(@work, @private_comment)
    assert_response :not_found
    patch student_task_path(@task), params: { task: { status: "completed" } }
    assert_equal "completed", @task.reload.status
    patch abnt_check_path(@check)
    assert @check.reload.human_checked_at
    assert_equal "suggestion", @check.status
    assert_difference "OrientationMessage.count", 1 do
      post orientation_messages_path, params: { content: "Enviei o quadro piloto." }
    end
    assert_equal @student.name, OrientationMessage.last.author_name
  end

  test "student meetings always create a private review" do
    assert_difference "ReviewRecord.count", 1 do
      post student_meetings_path, params: { meeting: { title: "Encontro novo", held_at: Time.current, summary: "NOVA SÍNTESE PRIVADA" } }
    end
    get student_meetings_path
    assert_no_match "NOVA SÍNTESE PRIVADA", response.body
  end

  test "exports and filtering work for the student" do
    [ export_work_path(@work), export_abnt_path, download_version_path(@work, @version) ].each do |path|
      get path
      assert_response :success
      assert response.headers["Content-Disposition"].include?("attachment")
    end
    get opportunity_recommendations_path(q: "no matching opportunity")
    assert_response :success
    assert_match "Nenhuma oportunidade", response.body
  end

  test "opportunities can be created recommended and acknowledged without external submission" do
    post opportunities_path, params: { opportunity_recommendation: { title: "Congresso novo", item_type: "congress", deadline_on: Date.tomorrow } }
    assert_redirected_to opportunity_recommendations_path
    post recommend_opportunity_path(@opportunity), params: { message: "Conferir chamada com a orientadora.", preparation_on: Date.tomorrow }
    assert @opportunity.reload.recommended_by.include?(@student.name)
    post acknowledge_opportunity_path(@opportunity)
    assert @opportunity.reload.acknowledged_at
  end

  private

  def pdf_upload
    Rack::Test::UploadedFile.new(StringIO.new(DemoDocument.pdf("Pesquisa", "Texto de teste")), "application/pdf", original_filename: "pesquisa.pdf")
  end
end
