require "test_helper"
require_relative "../support/portal_data"

class ProfessorActionsTest < ActionDispatch::IntegrationTest
  include PortalData
  setup { build_portal; sign_in(@professor) }

  test "professor creates edits and archives an orientando" do
    assert_difference "Student.count", 1 do
      post students_path, params: { student: { name: "Nova Pesquisadora", email: "nova@portal.test", password: "pesquisa2026", password_confirmation: "pesquisa2026", program: "Doutorado", project_title: "Autonomia docente" } }
    end
    student = Student.find_by!(email: "nova@portal.test")
    assert student.orientation
    assert_not student.trained?
    follow_redirect!
    assert_response :success
    patch student_path(student), params: { student: { progress: 40, name: "Pesquisadora Atualizada" } }
    assert_equal 40, student.reload.progress
    get students_path(student: student.id)
    assert_match "Pesquisadora Atualizada", response.body
    delete student_path(student)
    assert_not student.reload.active
    get students_path(archived: "1")
    assert_match "Pesquisadora Atualizada", response.body
  end

  test "professor records meetings tasks feedback schedule and messages" do
    assert_difference "ReviewRecord.count", 1 do
      post orientation_meetings_path(@orientation), params: { meeting: { title: "Reunião nova", held_at: Time.current, summary: "Resumo reservado" } }
    end
    follow_redirect!
    assert_response :success
    assert_difference "Task.count", 1 do
      post orientation_tasks_path(@orientation), params: { task: { title: "Preparar análise", due_on: Date.tomorrow } }
    end
    patch orientation_task_path(@orientation, Task.last), params: { task: { status: "completed" } }
    assert Task.last.completed_at
    assert_difference "ReviewRecord.count", 1 do
      post orientation_feedbacks_path(@orientation), params: { feedback: { content: "Rever a argumentação." } }
    end
    patch orientation_path(@orientation), params: { orientation: { next_meeting_at: "2027-01-10T14:00", notes: "Trazer quadro piloto" } }
    assert_equal "Trazer quadro piloto", @orientation.reload.notes
    post orientation_messages_path, params: { orientation_id: @orientation.id, content: "Vamos discutir o quadro." }
    assert_equal "professor", OrientationMessage.last.author_role
    get professor_meetings_path
    assert_match "Vamos discutir o quadro.", response.body
    get orientation_path(@orientation)
    assert_response :success
  end

  test "a student's manuscript question reaches the professor's conversation" do
    delete logout_path
    sign_in(@student)
    assert_difference "OrientationMessage.count", 1 do
      post academic_work_review_comments_path(@work), params: { review_comment: { content: "Como delimitar os eixos provisórios?" } }
    end
    delete logout_path
    sign_in(@professor)
    get professor_meetings_path
    assert_match "Como delimitar os eixos provisórios?", response.body
    assert_match @work.title, response.body
  end
end
