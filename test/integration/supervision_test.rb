require "test_helper"
require_relative "../support/portal_data"

class SupervisionTest < ActionDispatch::IntegrationTest
  include PortalData
  setup { build_portal }

  test "pending meeting content and exports are protected until explicit approval" do
    sign_in(@student)
    get student_meetings_path
    assert_no_match(/SÍNTESE PRIVADA|TRANSCRIÇÃO PRIVADA|ENCAMINHAMENTO PRIVADO/, response.body)
    get export_meeting_path(@meeting)
    assert_redirected_to student_meetings_path(meeting: @meeting.id)
    delete logout_path
    sign_in(@professor)
    get review_record_path(@record)
    assert_match "SÍNTESE PRIVADA", response.body
    prepare_publication
    patch review_record_path(@record), params: { operation: "publish", publication_scope: @record.reload.publication_scope, revision: @record.revision, confirmations: publication_confirmations }
    assert_redirected_to review_decision_path(@record)
    get review_decision_path(@record)
    assert_response :success
    delete logout_path
    sign_in(@student)
    get student_meetings_path
    assert_match "SÍNTESE PRIVADA", response.body
    assert_match "ENCAMINHAMENTO PRIVADO", response.body
    assert_no_match "TRANSCRIÇÃO PRIVADA", response.body
    get export_meeting_path(@meeting)
    assert_response :success
    assert_no_match "TRANSCRIÇÃO PRIVADA", response.body
  end

  test "cannot publish without source limits selected items and confirmations" do
    sign_in(@professor)
    patch review_record_path(@record), params: { operation: "publish", publication_scope: @record.reload.publication_scope, revision: 1, confirmations: publication_confirmations }
    assert_equal "pending", @record.reload.status
    prepare_publication
    patch review_record_path(@record), params: { operation: "publish", publication_scope: @record.reload.publication_scope, revision: 1 }
    assert_equal "pending", @record.reload.status
    patch review_record_path(@record), params: { operation: "publish", publication_scope: @record.reload.publication_scope, revision: 1, confirmations: publication_confirmations.except("scope") }
    assert_equal "pending", @record.reload.status
  end

  test "edits preserve original content create an audit snapshot and invalidate selection" do
    sign_in(@professor)
    prepare_publication
    original = @record.original_content.deep_dup
    patch review_record_path(@record), params: { operation: "edit", content: { summary: "Eixos provisórios, não conclusões finais." }, justification: "A fonte não comprova categorias finais." }
    assert_equal 2, @record.reload.revision
    assert_equal original, @record.original_content
    assert_empty @record.included_items
    assert_equal "Eixos provisórios, não conclusões finais.", @record.content["summary"]
    assert_equal "edited", @record.audit_events.last.action
    patch review_record_path(@record), params: { operation: "include", items: [ "summary" ] }
    patch review_record_path(@record), params: { operation: "publish", publication_scope: @record.reload.publication_scope, revision: 1, confirmations: publication_confirmations }
    assert_equal "editing", @record.reload.status
    patch review_record_path(@record), params: { operation: "publish", publication_scope: @record.reload.publication_scope, revision: 2, confirmations: publication_confirmations }
    assert_equal({ "summary" => "Eixos provisórios, não conclusões finais." }, @record.reload.published_content)
  end

  test "empty edit justification cannot mutate record" do
    sign_in(@professor)
    patch review_record_path(@record), params: { operation: "edit", content: { summary: "changed" }, justification: "" }
    assert_equal 1, @record.reload.revision
  end

  test "contest and reprocess preserve evidence and never execute inference" do
    sign_in(@professor)
    patch review_record_path(@record), params: { operation: "contest", note: "A conclusão extrapola a fonte." }
    assert_equal "contested", @record.audit_events.last.action
    assert_difference "ProcessingRequest.count", 1 do
      patch review_record_path(@record), params: { operation: "reprocess", instructions: "Usar somente as fontes carregadas." }
    end
    assert_equal "pending", ProcessingRequest.last.status
    assert_equal "local", ProcessingRequest.last.destination
    assert_equal "pending", @record.reload.status
  end

  test "rejection is recorded and cannot be silently published or edited" do
    sign_in(@professor)
    patch review_record_path(@record), params: { operation: "reject", reason: "Material insuficiente." }
    assert_equal "rejected", @record.reload.status
    patch review_record_path(@record), params: { operation: "edit", content: { summary: "replace" }, justification: "test" }
    assert_equal "rejected", @record.reload.status
    assert_equal 1, @record.revision
    assert_equal "rejected", @record.audit_events.last.action
  end

  test "other professor cannot read or mutate a review" do
    other = Professor.create!(name: "Outra Docente", email: "other@portal.test", password: "pesquisa2026")
    sign_in(other)
    get review_record_path(@record)
    assert_response :not_found
    patch review_record_path(@record), params: { operation: "publish", publication_scope: @record.reload.publication_scope, revision: 1, confirmations: publication_confirmations }
    assert_response :not_found
    assert_equal "pending", @record.reload.status
  end

  test "publication is final and versioned once" do
    prepare_publication
    sign_in(@professor)
    2.times { patch review_record_path(@record), params: { operation: "publish", publication_scope: @record.reload.publication_scope, revision: 1, confirmations: publication_confirmations } }
    assert_equal 1, @record.audit_events.where(action: "published").count
    assert_equal "published", @record.reload.status
  end

  test "scope changed in another window invalidates publication confirmation" do
    prepare_publication
    old_scope = @record.publication_scope
    @record.select_items!(@professor, %w[summary transcript])
    sign_in(@professor)
    patch review_record_path(@record), params: { operation: "publish", revision: 1, publication_scope: old_scope, confirmations: publication_confirmations }
    assert_equal "pending", @record.reload.status
    assert_empty @record.published_content
  end

  test "supervision path requires explicit understanding before review" do
    sign_in(@professor)
    get supervision_flow_path(@record, step: "review")
    assert_redirected_to supervision_flow_path(@record, step: "access")
    patch review_record_path(@record), params: { operation: "acknowledge", return_to: "flow", step: "review" }
    follow_redirect!
    assert_response :success
    assert_match "O que pode virar orientação?", response.body
  end

  test "meeting audio is scoped and withheld from the student until transcript publication" do
    @meeting.audio_file.attach(io: StringIO.new("RIFF\x00\x00\x00\x00WAVEfmt "), filename: "reuniao.wav", content_type: "audio/wav")
    sign_in(@student)
    get meeting_audio_path(@meeting)
    assert_response :not_found
    delete logout_path
    sign_in(@professor)
    get meeting_audio_path(@meeting)
    assert_response :success
    assert response.body.start_with?("RIFF")
    @record.acknowledge!(@professor)
    @record.mark_source!(@professor)
    @record.select_items!(@professor, [ "transcript" ])
    @record.publish!(@professor, expected_revision: 1, confirmations: publication_confirmations)
    delete logout_path
    sign_in(@student)
    get meeting_audio_path(@meeting)
    assert_response :success
    get student_meetings_path
    assert_select "audio source[src='#{meeting_audio_path(@meeting)}']"
  end

  test "rejecting one item and reverting edit preserve original and audit" do
    prepare_publication
    sign_in(@professor)
    patch review_record_path(@record), params: { operation: "reject", items: [ "summary" ], reason: "Extrapola a fonte." }
    assert_equal [ "next_steps" ], @record.reload.included_items
    assert_equal "pending", @record.status
    patch review_record_path(@record), params: { operation: "edit", content: { summary: "Edição temporária" }, justification: "Teste de revisão" }
    patch review_record_path(@record), params: { operation: "revert" }
    assert_equal @record.original_content, @record.reload.content
    assert_equal 3, @record.revision
    assert_empty @record.included_items
    assert_equal 2, @record.audit_events.where(action: "edited").count
  end
end
