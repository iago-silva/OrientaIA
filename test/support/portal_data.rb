module PortalData
  def build_portal
    @professor = Professor.create!(name: "Helena Duarte", email: "helena@portal.test", password: "pesquisa2026")
    @student = @professor.students.create!(name: "Marina Costa", email: "marina@portal.test", password: "pesquisa2026", program: "Mestrado", project_title: "IA na formação docente", training_completed_at: Time.current, training_step: 3, progress: 60)
    @orientation = @student.create_orientation!(professor: @professor, title: "Pesquisa em educação", next_meeting_at: 1.day.from_now)
    @meeting = @orientation.meetings.create!(title: "Teoria e categorias", held_at: Time.current, summary: "SÍNTESE PRIVADA NÃO PUBLICADA", next_steps: "ENCAMINHAMENTO PRIVADO", transcript: "TRANSCRIÇÃO PRIVADA")
    @record = @meeting.review_record
    @work = @student.academic_works.create!(title: "Capítulo 2", manuscript: "Texto original da aluna.\n\nDiscussão da formação docente.")
    @version = @work.work_versions.create!(version_number: 1, status: "approved", change_note: "Primeira versão")
    @comment = @work.review_comments.create!(work_version: @version, content: "Amplie o conceito.", author_name: @professor.name, published_at: Time.current)
    @private_comment = @work.review_comments.create!(work_version: @version, content: "COMENTÁRIO PRIVADO", author_name: @professor.name)
    @task = @orientation.tasks.create!(title: "Revisar capítulo", due_on: Date.tomorrow)
    @check = @work.abnt_checks.create!(code: "ABNT-1", category: "Citações", title: "Conferir recuo", status: "suggestion")
    @opportunity = @student.opportunity_recommendations.create!(title: "Dossiê Educação", item_type: "journal", deadline_on: Date.tomorrow)
  end

  def sign_in(user)
    post login_path, params: { email: user.email, password: "pesquisa2026" }
    assert_redirected_to root_path
  end

  def prepare_publication(record = @record)
    record.acknowledge!(@professor)
    record.mark_source!(@professor)
    record.select_items!(@professor, %w[summary next_steps])
  end

  def publication_confirmations
    %w[read justification transcript scope].index_with { "1" }
  end
end
