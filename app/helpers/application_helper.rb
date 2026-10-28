module ApplicationHelper
  def portal_icon(name, **options)
    if name.to_sym == :robot
      return image_tag("produc-robot.png", class: [ "portal-icon", "portal-robot", options[:class] ].compact.join(" "), alt: "", aria: { hidden: true }, width: 512, height: 512)
    end

    paths = {
      dashboard: '<rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/>',
      users: '<circle cx="9" cy="7" r="3"/><path d="M3 21v-3a6 6 0 0 1 12 0v3M16 4a3 3 0 0 1 0 6m2 4a5 5 0 0 1 3 4v3"/>',
      book: '<path d="M12 5v16M3 3h5a4 4 0 0 1 4 2 4 4 0 0 1 4-2h5v16h-5a4 4 0 0 0-4 2 4 4 0 0 0-4-2H3z"/>',
      chat: '<path d="M21 11a8 8 0 0 1-8 8H8l-5 3v-6a8 8 0 0 1 5-14h5a8 8 0 0 1 8 9Z"/><path d="M7 8h10M7 12h7"/>',
      calendar: '<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M7 3v4m10-4v4M3 11h18m-13 4h1m6 0h1"/>',
      document: '<path d="M14 2H5v20h14V7zM14 2v5h5M8 12h8m-8 4h8"/>',
      search: '<circle cx="10" cy="10" r="7"/><path d="m15 15 6 6M7 10l2 2 4-4"/>',
      clock: '<circle cx="12" cy="12" r="9"/><path d="M12 6v6l4 2"/>',
      user: '<circle cx="12" cy="8" r="4"/><path d="M4 22v-3a8 8 0 0 1 16 0v3"/>',
      plus: '<circle cx="12" cy="12" r="9"/><path d="M12 7v10M7 12h10"/>',
      edit: '<path d="m15 4 5 5M4 20l5-1L21 7a2 2 0 0 0-5-5L4 14zM13 21h8"/>',
      check: '<path d="m5 12 4 4L19 6"/>',
      cap: '<path d="m2 8 10-5 10 5-10 5zM6 10v7c4 3 8 3 12 0v-7m4-2v9"/>',
      send: '<path d="m22 2-7 20-4-9-9-4zM11 13 22 2"/>'
    }
    tag.svg(viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", "stroke-width": 1.5, "stroke-linecap": "round", "stroke-linejoin": "round", class: [ "portal-icon", options[:class] ].compact.join(" "), "aria-hidden": true) do
      paths.fetch(name.to_sym, paths[:document]).html_safe
    end
  end

  def portal_navigation
    items = if current_student
      [
        [ "Dashboard", root_path, :dashboard, %w[dashboard] ],
        [ "Trabalhos", academic_works_path, :book, %w[academic_works work_versions review_comments] ],
        [ "Análise ABNT", abnt_analysis_path, :search, %w[abnt_analyses abnt_checks] ],
        [ "Agenda", student_agenda_path, :calendar, %w[student_agenda student_tasks] ],
        [ "Reuniões", student_meetings_path, :users, %w[student_meetings] ],
        [ "Submissões", opportunity_recommendations_path, :document, %w[opportunity_recommendations] ],
        [ "Chat com IA", assistant_path, :chat, %w[assistant] ]
      ]
    else
      [
        [ "Dashboard", root_path, :dashboard, %w[dashboard] ],
        [ "Alunos", students_path, :users, %w[students] ],
        [ "Orientações", orientations_path, :book, %w[orientations meetings tasks feedbacks] ],
        [ "Chat com IA", assistant_path, :chat, %w[assistant] ]
      ]
    end
    items.map { |label, path, icon, controllers| { label: label, path: path, icon: icon, active: controllers.include?(controller_name) } }
  end

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
