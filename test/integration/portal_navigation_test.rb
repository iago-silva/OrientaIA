require "test_helper"
require_relative "../support/portal_data"

class PortalNavigationTest < ActionDispatch::IntegrationTest
  include PortalData
  setup { build_portal }

  test "every professor screen renders with the new identity" do
    @record.acknowledge!(@professor)
    sign_in(@professor)
    paths = [ root_path, students_path, new_student_path, edit_student_path(@student), orientations_path, orientation_path(@orientation), professor_meetings_path, supervision_path, supervision_path(tab: "history"), review_record_path(@record), review_trail_path(@record), privacy_path, guide_path, assistant_path, new_opportunity_path ]
    %w[access review confirm].each { |step| paths << supervision_flow_path(@record, step: step) }
    paths.each do |path|
      get path
      assert_response :success, path
      assert_select "title", /OrientaAI/
      assert_select ".side-nav a", count: 5
      assert_no_match(/PRODUC|Translation missing|undefined method/i, response.body)
    end
  end

  test "every student screen renders without a professor action" do
    sign_in(@student)
    paths = [ root_path, academic_works_path, academic_work_path(@work), academic_work_path(@work, filter: "all"), compare_work_path(@work), abnt_analysis_path, abnt_analysis_path(category: "all"), student_agenda_path, student_meetings_path, opportunity_recommendations_path, opportunity_recommendations_path(filter: "recommended"), new_opportunity_path, opportunity_path(@opportunity), privacy_path, guide_path, assistant_path ]
    3.times { |step| paths << training_path(step: step) }
    paths.each do |path|
      get path
      assert_response :success, path
      assert_select "title", /OrientaAI/
      assert_no_match(/COMENTÁRIO PRIVADO|SÍNTESE PRIVADA NÃO PUBLICADA|ENCAMINHAMENTO PRIVADO|TRANSCRIÇÃO PRIVADA/, response.body)
    end
  end

  test "authentication invalid credentials and logout" do
    get root_path
    assert_redirected_to login_path
    post login_path, params: { email: @student.email, password: "wrong" }
    assert_response :unprocessable_entity
    sign_in(@student)
    delete logout_path
    get root_path
    assert_redirected_to login_path
  end

  test "registration validates and opens an empty working professor portal" do
    post signup_path, params: { professor: { name: "", email: "", password: "short" } }
    assert_response :unprocessable_entity
    post signup_path, params: { professor: { name: "Nova Docente", email: "nova@portal.test", password: "pesquisa2026", password_confirmation: "pesquisa2026" } }
    assert_redirected_to root_path
    [ root_path, supervision_path, students_path, professor_meetings_path, privacy_path ].each do |path|
      get path
      assert_response :success
    end
  end

  test "invalid and cross account records return 404 rather than error pages" do
    sign_in(@student)
    get academic_work_path(999999)
    assert_response :not_found
    assert_select "h1", "Página não encontrada."
    get students_path
    assert_redirected_to root_path
    get review_record_path(@record)
    assert_redirected_to root_path
  end

  test "student with no research or meetings can navigate empty states" do
    @orientation.destroy!
    @student.academic_works.destroy_all
    sign_in(@student)
    [ root_path, student_meetings_path, academic_works_path, student_agenda_path, privacy_path, abnt_analysis_path ].each do |path|
      get path
      assert_response :success, path
    end
  end
end
