module ApplicationHelper
  def initials(name)
    name.to_s.split.map { |part| part[0] }.first(2).join.upcase
  end

  def formatted_status(status)
    { "active" => "Ativa", "paused" => "Pausada", "completed" => "Concluída" }.fetch(status, status.to_s.humanize)
  end

  def student_section_name
    case controller_name
    when "dashboard" then "Painel"
    when "academic_works", "work_versions", "review_comments" then "Trabalhos"
    when "abnt_analyses", "abnt_checks" then "Análise ABNT"
    when "student_agenda", "student_tasks" then "Agenda"
    when "student_meetings" then "Reuniões"
    when "opportunity_recommendations" then "Submissões"
    else "Meu espaço"
    end
  end
end
