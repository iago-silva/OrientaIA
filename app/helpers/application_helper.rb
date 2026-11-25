module ApplicationHelper
  def portal_icon(name, **options)
    paths = {
      dashboard: '<rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/>',
      book: '<path d="M12 5v16M3 3h5a4 4 0 0 1 4 2 4 4 0 0 1 4-2h5v16h-5a4 4 0 0 0-4 2 4 4 0 0 0-4-2H3z"/>',
      users: '<circle cx="9" cy="7" r="3"/><path d="M3 21v-3a6 6 0 0 1 12 0v3M16 4a3 3 0 0 1 0 6m2 4a5 5 0 0 1 3 4v3"/>',
      calendar: '<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M7 3v4m10-4v4M3 11h18m-13 4h1m6 0h1"/>',
      document: '<path d="M14 2H5v20h14V7zM14 2v5h5M8 12h8m-8 4h8"/>',
      check: '<path d="m5 12 4 4L19 6"/>',
      shield: '<path d="m12 2 8 4v6c0 5-8 10-8 10S4 17 4 12V6z"/><path d="m8 11 3 3 5-6"/>',
      lock: '<rect x="5" y="10" width="14" height="11" rx="2"/><path d="M8 10V6a4 4 0 0 1 8 0v4m-4 4v3"/>',
      chat: '<path d="M21 4H3v14h5l4 4v-4h9z"/>',
      search: '<circle cx="10" cy="10" r="6"/><path d="m15 15 6 6"/>',
      upload: '<path d="M7 16H5a4 4 0 0 1-1-8 7 7 0 0 1 13-2 5 5 0 0 1 2 10h-2M12 22V10m-4 4 4-4 4 4"/>',
      send: '<path d="m22 2-7 20-4-9-9-4zM11 13 22 2"/>',
      clock: '<circle cx="12" cy="12" r="9"/><path d="M12 6v6l4 2"/>',
      bell: '<path d="M5 17h14l-2-3V9a5 5 0 0 0-10 0v5zM10 21h4"/>',
      edit: '<path d="m15 4 5 5M4 20l5-1L21 7a2 2 0 0 0-5-5L4 14zM13 21h8"/>',
      download: '<path d="M12 3v12m-4-4 4 4 4-4M3 17v4h18v-4"/>',
      flag: '<path d="M5 22V3h14l-3 5 3 5H5"/>',
      cap: '<path d="m2 8 10-5 10 5-10 5zM6 10v7c4 3 8 3 12 0v-7m4-2v9"/>',
      spark: '<path d="m12 2 2.5 7.5L22 12l-7.5 2.5L12 22l-2.5-7.5L2 12l7.5-2.5z"/>',
      info: '<circle cx="12" cy="12" r="9"/><path d="M12 11v6m0-11v1"/>',
      plus: '<path d="M12 4v16M4 12h16"/>',
      microphone: '<rect x="9" y="2" width="6" height="13" rx="3"/><path d="M5 10v2a7 7 0 0 0 14 0v-2M12 19v3m-4 0h8"/>'
    }
    tag.svg(viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", "stroke-width": 1.6, "stroke-linecap": "round", "stroke-linejoin": "round", class: [ "icon", options[:class] ].compact.join(" "), "aria-hidden": true) { paths.fetch(name.to_sym, paths[:document]).html_safe }
  end

  def portal_logo
    tag.svg(viewBox: "0 0 32 32", fill: "none", class: "logo-mark", "aria-hidden": true) do
      '<rect width="32" height="32" rx="9" fill="#1b6c76"/><path d="M21 10c-10-2-14 11-6 13 6 2 12-5 10-13M11 19c7 2 12-9 7-10-5-1-10 6-8 10m4-1c5-3 5-7 5-7" stroke="#e8f6f4" stroke-width="1.5" stroke-linecap="round"/>'.html_safe
    end
  end

  def portal_navigation
    student = [ [ "Painel", root_path, :dashboard, %w[dashboard] ], [ "Trabalhos", academic_works_path, :document, %w[academic_works work_versions review_comments] ], [ "Análise ABNT", abnt_analysis_path, :check, %w[abnt_analyses abnt_checks] ], [ "Agenda", student_agenda_path, :calendar, %w[student_agenda student_tasks] ], [ "Reuniões", student_meetings_path, :chat, %w[student_meetings orientation_messages] ], [ "Submissões", opportunity_recommendations_path, :book, %w[opportunity_recommendations opportunities] ], [ "Privacidade", privacy_path, :shield, %w[privacy] ] ]
    professor = [ [ "Painel docente", root_path, :dashboard, %w[dashboard] ], [ "Validação docente", supervision_path, :document, %w[supervision] ], [ "Orientandos", students_path, :users, %w[students orientations] ], [ "Reuniões", professor_meetings_path, :chat, %w[professor_meetings meetings] ], [ "Privacidade", privacy_path, :shield, %w[privacy] ] ]
    items = current_student ? student : professor
    items = [ [ "Formação inicial", training_path, :cap, %w[training] ], *items ] if current_student && (!current_student.trained? || controller_name == "training")
    items.map { |label, path, icon, controllers| { label: label, path: path, icon: icon, active: controllers.include?(controller_name), locked: current_student && !current_student.trained? && !%w[training privacy].include?(controllers.first) } }
  end

  def initials(name)
    name.to_s.split.first(2).map { |part| part[0] }.join.upcase
  end

  def section_name
    portal_navigation.find { |item| item[:active] }&.fetch(:label) || "Meu espaço"
  end

  def label_for_status(value)
    { "pending" => "Aguardando validação", "editing" => "Em revisão", "published" => "Aprovado pela orientadora", "rejected" => "Rejeitado", "received" => "Em preparação", "reviewing" => "Em análise", "approved" => "Aprovada · docente", "revision_requested" => "Revisão solicitada", "active" => "Ativa", "completed" => "Concluída", "paused" => "Pausada", "open" => "Não revisada", "resolved" => "Revisada por você" }.fetch(value.to_s, value.to_s.humanize)
  end

  def formatted_status(value)
    label_for_status(value)
  end

  def date_text(value, format = "%d %b %Y")
    value ? l(value, format: format) : "A definir"
  end

  def focused_student
    current_student || current_professor&.students&.order(:id)&.first
  end

  def review_item_label(key)
    { "summary" => "Síntese", "next_steps" => "Encaminhamento", "transcript" => "Transcrição" }.fetch(key, key)
  end

  def audit_label(action)
    { "created" => "Rascunho criado · pendente de revisão", "edited" => "Edição parcial salva · pendente de aprovação", "source_checked" => "Fonte conferida", "limits_acknowledged" => "Limites da IA reconhecidos", "scope_selected" => "Escopo selecionado", "published" => "Aprovação explícita · publicado", "rejected" => "Proposta rejeitada", "item_rejected" => "Item rejeitado · evidência preservada", "contested" => "Contestação registrada", "reprocessing_requested" => "Reprocessamento solicitado · pendente" }.fetch(action, action.humanize)
  end
end
