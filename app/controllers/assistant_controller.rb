class AssistantController < ApplicationController
  before_action :require_professor!
  def show
    @token = ENV.fetch("ROBOT_API_TOKEN", "demo-robot-token")
    @base_url = request.base_url
  end
end
