unless Professor.exists?(email: "helena@orienta.demo")
  Professor.transaction do
    helena = Professor.create!(name: "Helena Duarte", email: "helena@orienta.demo", password: "pesquisa2026", institution: "Mestrado em Educação")
    marina = helena.students.create!(name: "Marina Costa", email: "marina@orienta.demo", password: "pesquisa2026", program: "Mestrado", research_area: "Educação e tecnologias", project_title: "Inteligência artificial na formação docente: práticas e percepções no ensino superior", progress: 60, training_step: 3, training_completed_at: Time.zone.parse("2026-09-01 10:00"), research_problem: "Como a inteligência artificial transforma as práticas de formação docente e a autonomia dos professores?", objectives: "Compreender as práticas, percepções e limites da IA na formação docente no ensino superior.", methodology: "Pesquisa qualitativa com entrevistas, análise documental e análise temática.")
    orientation = marina.create_orientation!(professor: helena, title: marina.project_title, next_meeting_at: Time.zone.parse("2026-10-06 14:00"), notes: "Relacionar os eixos provisórios ao referencial e aos trechos do material empírico.")
    helena.students.create!(name: "Lara Almeida", email: "nova.aluna@orienta.demo", password: "pesquisa2026", program: "Mestrado", research_area: "Educação e tecnologias", project_title: "Formação docente e autonomia acadêmica", active: false, progress: 0)
    text = "A inserção da inteligência artificial no ensino superior amplia o debate sobre as competências necessárias à formação de professores. Para além do domínio instrumental, seu uso demanda reflexão sobre o contexto pedagógico e as decisões tomadas em sala de aula.\n\nNesse sentido, o letramento digital pode ser compreendido como um conjunto de habilidades para utilizar recursos tecnológicos. A formação docente deve acompanhar essas transformações, incorporando novas ferramentas às práticas de ensino.\n\nEsta pesquisa investiga como docentes percebem a presença da IA em seus processos formativos. Busca-se compreender não apenas a adoção de ferramentas, mas também os sentidos atribuídos a elas e as tensões entre inovação, autonomia e responsabilidade."
    works = []
    [ [ "Capítulo 2 · Referencial teórico", "Capítulo", 3 ], [ "Capítulo 3 · Metodologia", "Capítulo", 2 ], [ "Dissertação", "Dissertação", 3 ] ].each do |title, category, count|
      work = marina.academic_works.create!(title: title, category: category, status: "reviewed", current_version: count, manuscript: text)
      count.times do |index|
        version = work.work_versions.create!(version_number: index + 1, label: "Versão #{index + 1}", change_note: [ "Primeira estrutura do capítulo", "Amplia diálogo entre autores", "Inclui debate sobre letramento digital" ][index], status: index == count - 1 ? "approved" : "received", created_at: Time.zone.parse("2026-09-#{15 + index * 7} 10:15"))
        version.file.attach(io: StringIO.new(DemoDocument.pdf(title, text)), filename: "#{title.parameterize}_v#{index + 1}.pdf", content_type: "application/pdf")
      end
      works << work
    end
    work = works.first
    comments = [ [ "Argumentação", "Amplie o conceito de letramento", "O trecho limita o conceito ao uso de ferramentas. Como a dimensão crítica se relaciona à sua pergunta?" ], [ "Coerência", "Conecte teoria e pesquisa", "Explique como os conceitos desta seção sustentam suas categorias de análise." ], [ "Clareza", "Delimite ‘transformações’", "Indique quais mudanças nas práticas docentes estão sendo discutidas." ] ]
    12.times do |index|
      section, title, content = comments[index % 3]
      work.review_comments.create!(work_version: work.latest_version, section: section, content: "#{title}\n#{content}", anchor_text: "A formação docente envolve práticas que articulam conhecimentos, experiências e reflexão sobre o ensino.", author_name: helena.name, status: index < 3 ? "open" : "resolved", published_at: Time.zone.parse("2026-10-01 10:15"))
    end
    work_review = ReviewRecord.create!(orientation: orientation, work_version: work.latest_version, title: "Referencial teórico", kind: "work", revision: 3, original_content: { summary: "Boa base conceitual. O próximo avanço é conectar os autores à sua pergunta de pesquisa.", next_steps: "Retome os comentários publicados e revise o capítulo.", transcript: "" }, evidence: "Capítulo 2, páginas 12–13; texto fornecido pela aluna.")
    work_review.acknowledge!(helena)
    work_review.mark_source!(helena)
    work_review.select_items!(helena, %w[summary next_steps])
    work_review.publish!(helena, expected_revision: 3, confirmations: %w[read justification transcript scope].index_with { "1" })
    [ [ "Teoria e categorias de análise", "2026-09-29 14:00" ], [ "Revisão da metodologia", "2026-09-22 14:00" ], [ "Letramento digital crítico", "2026-09-15 10:00" ], [ "Plano de qualificação", "2026-09-08 14:00" ] ].each_with_index do |(title, time), index|
      meeting = orientation.meetings.create!(title: title, held_at: Time.zone.parse(time), source: "web", transcript: "Helena: Vamos testar esses eixos no quadro piloto antes de fechar as categorias.\nMarina: Vou preparar o quadro com definições e trechos do material.\nHelena: Retomamos o quadro na próxima reunião.", summary: index.zero? ? "A reunião definiu três categorias finais: uso instrumental, reflexão crítica e autonomia docente. A literatura confirma a adequação do quadro." : "Revisamos o percurso da pesquisa e discutimos os próximos passos.", next_steps: "Preparar quadro piloto com definições e trechos do material para o próximo encontro.", external_id: "demo-reuniao-#{index + 1}")
      review = meeting.review_record
      review.event!(helena, "created", { source: "Amostra demonstrativa, sem LLM conectado" })
      if index.zero?
        review.update!(evidence: "Anotações da reunião ‘Teoria e categorias de análise’, 29 set. 2026. Trecho 09:08–09:32: ‘Vamos testar esses eixos no quadro piloto antes de fechar as categorias.’ Capítulo 2, páginas 12–13. Critério: fidelidade ao material e distinção entre hipótese e decisão.")
        review.save_edit!(helena, { summary: "Foram discutidos eixos provisórios de análise: uso instrumental, reflexão crítica e autonomia docente. O quadro ainda precisa ser confrontado com o referencial e com o material empírico.", next_steps: "Marina preparará um quadro piloto com definições e trechos do material. Retomar com a orientadora em 6 out." }, "Retirei a afirmação de validação: os eixos ainda são provisórios. Marina, relacione cada definição a um trecho do material antes de ampliarmos a análise.")
      elsif index < 3
        review.acknowledge!(helena)
        review.mark_source!(helena)
        review.select_items!(helena, %w[summary next_steps transcript])
        review.publish!(helena, expected_revision: review.revision, confirmations: %w[read justification transcript scope].index_with { "1" })
      else
        review.reject!(helena, "Somente anotações de pauta. Nenhuma síntese automática a publicar.")
      end
      [ marina, helena ].each do |person|
        consent = orientation.consents.create!(meeting: meeting, participant: person, purpose: "recording", granted: true, accepted_at: Time.zone.parse(time) - 2.minutes, scope: "Áudio e transcrição da reunião #{title}; memória da orientação; sem envio externo.")
        consent.consent_events.create!(action: "granted", actor: person.name, term_version: "1.0", scope: consent.scope)
      end
    end
    feedback = orientation.feedbacks.create!(author_name: helena.name, content: "Plano da discussão dos resultados", source: "web")
    feedback.review_record.event!(helena, "created", { note: "Rascunho aguardando revisão humana" })
    [ [ "Revisar 3 comentários", "Referencial teórico · prioridade", "2026-10-05" ], [ "Conferir 8 achados ABNT", "Dissertação · versão 3", "2026-10-06" ], [ "Preparar pauta da reunião", "Quadro piloto de análise", "2026-10-06" ] ].each do |title, description, due|
      orientation.tasks.create!(title: title, description: description, due_on: Date.parse(due), status: "pending", source: "web")
    end
    orientation.orientation_messages.create!(author_name: marina.name, author_role: "student", content: "Anexei a versão 3 do capítulo 2 para discutirmos hoje.", created_at: Time.zone.parse("2026-09-29 13:40"))
    orientation.orientation_messages.create!(author_name: helena.name, author_role: "professor", content: "Registrei os encaminhamentos. Vamos retomar o quadro na próxima reunião.", created_at: Time.zone.parse("2026-09-29 15:02"))
    categories = [ [ "Estrutura do trabalho", 6 ], [ "Formatação", 5 ], [ "Citações", 9 ], [ "Referências", 4 ] ]
    count = 0
    categories.each do |category, quantity|
      quantity.times do |index|
        status = count < 16 ? "verified" : (count < 21 ? "suggestion" : "manual_review")
        title = category == "Citações" && index == 5 ? "Citação longa sem destaque de recuo" : category == "Citações" && index == 6 ? "Citação direta sem indicação de página" : "#{category} · requisito #{index + 1}"
        work.abnt_checks.create!(work_version: work.latest_version, code: "ABNT-#{count + 1}", category: category, title: title, status: status, page_number: 42 + index, section: "2.#{index + 1}", excerpt: "A formação docente envolve práticas que articulam conhecimentos, experiências e reflexão sobre o ensino…", recommendation: "Confira o texto e as regras no documento original. Para citações diretas longas, use recuo padronizado e identifique a página quando disponível. Não invente informação.")
        count += 1
      end
    end
    [ [ "Dossiê · IA e formação docente", "journal", "Revista Horizontes da Educação", "2026-10-30" ], [ "Congresso de Educação e Tecnologias", "congress", "Instituto Horizonte", "2026-10-15" ], [ "Seminário de Pesquisa em Formação Docente", "event", "Rede Formação em Diálogo", "2026-09-25" ] ].each_with_index do |(title, type, organization, deadline), index|
      marina.opportunity_recommendations.create!(title: title, item_type: type, organization: "#{organization} · organização fictícia", subject: "Inteligência artificial · Letramento digital · Formação docente", deadline_on: Date.parse(deadline), description: "Chamada demonstrativa para discutir práticas e pesquisas de formação docente. Nenhuma submissão externa é realizada.", reason: "Dialoga com o tema da pesquisa e com os eixos de análise.", recommended_by: index == 2 ? helena.name : nil, acknowledged_at: index == 2 ? Time.zone.parse("2026-09-18 10:00") : nil, relevance: 98 - index * 5, status: "recommended")
    end
  end
end
puts "OrientaAI pronto. Professora: helena@orienta.demo; aluna: marina@orienta.demo; formação: nova.aluna@orienta.demo. Senha demonstrativa: pesquisa2026."
