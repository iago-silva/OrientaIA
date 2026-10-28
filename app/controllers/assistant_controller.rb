class AssistantController < ApplicationController
  def show
    return if current_student

    @token_configured = ENV["ROBOT_API_TOKEN"].present?
    @token = ENV.fetch("ROBOT_API_TOKEN", "demo-robot-token") if Rails.env.development?
    @base_url = request.base_url
  end
end
