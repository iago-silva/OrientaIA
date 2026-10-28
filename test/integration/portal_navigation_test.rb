require "test_helper"

class PortalNavigationTest < ActionDispatch::IntegrationTest
  setup do
    @professor = Professor.create!(name: "Ana Silva", email: "ana@portal.test", password: "pesquisa2026")
    @student = @professor.students.create!(name: "João Santos", email: "joao@portal.test", program: "Mestrado", password: "pesquisa2026", progress: 40)
    @orientation = @student.create_orientation!(professor: @professor, title: "Pesquisa de mestrado")
    @work = @student.academic_works.create!(title: "Capítulo de pesquisa")
  end

  test "professor can navigate the portal and open grouped orientations" do
    sign_in(@professor)
    [ root_path, students_path, new_student_path, edit_student_path(@student), orientations_path, orientation_path(@orientation), assistant_path ].each do |path|
      get path
      assert_response :success
      assert_select "nav.portal-nav a", count: 4
      assert_select "nav a[aria-current=page]", count: 1
    end
    get orientations_path
    assert_select "details.orientation-group", count: 2
    assert_select "a[href='#{orientation_path(@orientation)}']", text: /João Santos/
    get students_path
    assert_no_match(/Translation missing/i, response.body)
    get assistant_path
    assert_select ".robot-integration"
    assert_select "title", "Chat IA · PRODUC"
  end

  test "student can navigate every research section in the shared layout" do
    sign_in(@student)
    [ root_path, academic_works_path, academic_work_path(@work), abnt_analysis_path, student_agenda_path, student_meetings_path, opportunity_recommendations_path, assistant_path ].each do |path|
      get path
      assert_response :success
      assert_select ".student-portal"
      assert_select "nav.portal-nav a", count: 7
      assert_select "nav a[aria-current=page]", count: 1
      assert_select ".student-sidebar", count: 0
    end
  end

  test "student assistant does not expose the professor integration or token" do
    sign_in(@student)
    get assistant_path
    assert_response :success
    assert_select ".robot-integration", count: 0
    assert_select ".token-box", count: 0
    assert_select "textarea[disabled]"
    assert_select "a[href='#{student_agenda_path}']", text: /Organizar próximos passos/
    get students_path
    assert_redirected_to root_path
  end

  test "anonymous access is redirected and login rejects invalid credentials" do
    get assistant_path
    assert_redirected_to login_path
    get login_path
    assert_response :success
    assert_select "form[action='#{login_path}'] input[name=email]"
    post login_path, params: { email: @student.email, password: "incorreta" }
    assert_response :unprocessable_entity
    assert_select "[role=alert]", text: /E-mail ou senha inválidos/
  end

  test "registration shows validation errors in the new card" do
    get signup_path
    assert_response :success
    post signup_path, params: { professor: { name: "", email: "", password: "", password_confirmation: "" } }
    assert_response :unprocessable_entity
    assert_select ".produc-auth-card .form-errors"
  end

  test "shared logout form ends the session" do
    sign_in(@student)
    delete logout_path
    assert_redirected_to login_path
    get root_path
    assert_redirected_to login_path
  end

  private

  def sign_in(user)
    post login_path, params: { email: user.email, password: "pesquisa2026" }
    assert_redirected_to root_path
  end
end
