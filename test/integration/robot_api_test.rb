require "test_helper"
require_relative "../support/portal_data"

class RobotApiTest < ActionDispatch::IntegrationTest
  include PortalData
  setup do
    build_portal
    @old_email = ENV["ROBOT_PROFESSOR_EMAIL"]
    @old_token = ENV["ROBOT_API_TOKEN"]
    ENV["ROBOT_PROFESSOR_EMAIL"] = @professor.email
    ENV["ROBOT_API_TOKEN"] = "robot-test-secret"
    @headers = { "Authorization" => "Bearer robot-test-secret" }
  end
  teardown do
    ENV["ROBOT_PROFESSOR_EMAIL"] = @old_email
    ENV["ROBOT_API_TOKEN"] = @old_token
  end

  test "robot authenticates and cannot publish human decisions" do
    get "/api/v1/overview"
    assert_response :unauthorized
    get "/api/v1/overview", headers: @headers
    assert_response :success
    post "/api/v1/orientations/#{@orientation.id}/meetings", params: { meeting: { title: "Gravação do robô", held_at: Time.current, summary: "RESUMO DO ROBÔ PRIVADO", external_id: "voice-001" } }, headers: @headers
    assert_response :created
    record = Meeting.find_by!(external_id: "voice-001").review_record
    assert_equal "pending", record.status
    assert_no_difference "Meeting.count" do
      post "/api/v1/orientations/#{@orientation.id}/meetings", params: { meeting: { title: "Gravação do robô", held_at: Time.current, external_id: "voice-001" } }, headers: @headers
    end
    assert_response :success
    sign_in(@student)
    get student_meetings_path
    assert_no_match "RESUMO DO ROBÔ PRIVADO", response.body
  end
end
