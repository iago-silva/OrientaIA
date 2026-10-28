professor = Professor.find_or_initialize_by(email: "cynara@produc.demo")
professor.assign_attributes(
  name: "Cynara Carvalho",
  institution: "PPGEC · Portal de demonstração",
  password: "produc2026",
  password_confirmation: "produc2026"
)
professor.save!

sample_students = [
  {
    name: "Ana Luiza Ferreira", email: "ana.ferreira@aluno.demo", program: "Doutorado",
    research_area: "Interação Humano-Computador", project_title: "Apoio inteligente à orientação acadêmica",
    research_problem: "Como ferramentas conversacionais podem apoiar o acompanhamento de pesquisas de pós-graduação sem substituir a relação entre orientador e orientando?",
    objectives: "Investigar necessidades de professores e estudantes; prototipar fluxos de registro; avaliar a utilidade dos resumos e próximos passos.",
    methodology: "Estudo de caso com entrevistas semiestruturadas, prototipação participativa e avaliação qualitativa.", progress: 72,
    next_meeting_in: 2, next_hour: 14, tasks: [ [ "Revisar roteiro das entrevistas", 3, "Conferir alinhamento entre perguntas e objetivos específicos." ], [ "Enviar versão do capítulo de método", 8, "Incluir os critérios de seleção dos participantes." ] ],
    meeting_title: "Delimitação dos critérios de avaliação", meeting_summary: "A conversa definiu os critérios para avaliar clareza, continuidade e utilidade dos registros de orientação.",
    next_steps: "Revisar o roteiro de entrevistas e enviar a nova versão antes do próximo encontro."
  },
  {
    name: "Marcos Vinícius Rocha", email: "marcos.rocha@aluno.demo", program: "Mestrado",
    research_area: "Engenharia de Software", project_title: "Práticas de documentação em equipes de software",
    research_problem: "Quais fatores influenciam a manutenção de documentação útil em equipes de desenvolvimento ágil?",
    objectives: "Mapear práticas de documentação; identificar barreiras de adoção; propor recomendações aplicáveis a equipes de pequeno porte.",
    methodology: "Revisão de literatura e estudo exploratório com entrevistas e análise temática.", progress: 46,
    next_meeting_in: 4, next_hour: 10, tasks: [ [ "Refinar pergunta de pesquisa", 2, "Trazer duas versões alternativas para discutirmos." ], [ "Mapear estudos recentes", 12, "Registrar bases, strings e critérios de inclusão." ] ],
    meeting_title: "Refinamento da pergunta de pesquisa", meeting_summary: "Reduzimos o escopo para práticas de documentação mantidas junto ao código e aos fluxos de trabalho.",
    next_steps: "Propor duas formulações da pergunta e iniciar o protocolo de busca."
  },
  {
    name: "Júlia Mendes Costa", email: "julia.mendes@aluno.demo", program: "Mestrado",
    research_area: "Educação em Engenharia", project_title: "Estratégias de aprendizagem ativa em disciplinas de computação",
    research_problem: "Que condições favorecem a participação de estudantes em atividades de aprendizagem ativa nos cursos de computação?",
    objectives: "Descrever estratégias adotadas; compreender a experiência dos estudantes; analisar fatores de participação.",
    methodology: "Estudo qualitativo com observação de aulas, diário de campo e grupos focais.", progress: 28,
    next_meeting_in: 7, next_hour: 15, tasks: [ [ "Organizar referências do referencial", 5, "Agrupar por conceito e registrar sínteses curtas." ] ],
    meeting_title: "Estrutura inicial do referencial", meeting_summary: "Agrupamos as referências em participação, desenho instrucional e aprendizagem ativa.",
    next_steps: "Montar um mapa conceitual e anotar lacunas da revisão."
  },
  {
    name: "Pedro Henrique Alves", email: "pedro.alves@aluno.demo", program: "Doutorado",
    research_area: "Sistemas de Informação", project_title: "Colaboração e conhecimento em ambientes digitais",
    research_problem: "Como a organização do conhecimento em ambientes digitais afeta a colaboração em grupos de pesquisa?",
    objectives: "Compreender práticas colaborativas; analisar mecanismos de compartilhamento; propor um modelo conceitual.",
    methodology: "Estudo de casos múltiplos com análise documental e entrevistas com pesquisadores.", progress: 61,
    next_meeting_in: nil, next_hour: nil, tasks: [ [ "Consolidar categorias de análise", 10, "Rever as categorias emergentes nas entrevistas-piloto." ] ],
    meeting_title: "Discussão das entrevistas-piloto", meeting_summary: "As entrevistas indicam diferenças entre compartilhamento de arquivos e construção coletiva de conhecimento.",
    next_steps: "Consolidar as categorias de análise antes de iniciar a próxima rodada."
  }
]

sample_students.each do |attributes|
  student = professor.students.find_or_initialize_by(email: attributes[:email])
  student.assign_attributes(attributes.except(:next_meeting_in, :next_hour, :tasks, :meeting_title, :meeting_summary, :next_steps))
  student.save!

  orientation = professor.orientations.find_or_initialize_by(student: student)
  orientation.assign_attributes(
    title: student.project_title,
    status: "active",
    next_meeting_at: attributes[:next_meeting_in] && (Time.current + attributes[:next_meeting_in].days).change(hour: attributes[:next_hour], min: 0)
  )
  orientation.save!

  attributes[:tasks].each do |title, days, description|
    task = orientation.tasks.find_or_initialize_by(title: title)
    task.assign_attributes(description: description, due_on: Date.current + days.days, status: "pending", source: "web")
    task.save!
  end

  meeting = orientation.meetings.find_or_initialize_by(external_id: "seed-#{student.id}")
  meeting.assign_attributes(
    held_at: Time.current - 2.days,
    title: attributes[:meeting_title],
    summary: attributes[:meeting_summary],
    next_steps: attributes[:next_steps],
    source: "web"
  )
  meeting.save!

  feedback_text = "Boa evolução. Mantenha os objetivos alinhados à pergunta de pesquisa e registre as decisões de método."
  orientation.feedbacks.find_or_create_by!(content: feedback_text) do |feedback|
    feedback.author_name = professor.name
    feedback.source = "web"
  end
end

marina = professor.students.find_or_initialize_by(email: "marina.costa@orienta.demo")
marina.assign_attributes(
  name: "Marina Costa",
  program: "Mestrado",
  research_area: "Formação docente",
  project_title: "Inteligência artificial na formação docente: práticas e percepções no ensino superior",
  research_problem: "Como docentes do ensino superior percebem e incorporam ferramentas de inteligência artificial generativa em suas práticas de ensino?",
  objectives: "Compreender práticas e percepções docentes sobre IA generativa; identificar oportunidades e preocupações; propor orientações para uso crítico no ensino superior.",
  methodology: "Pesquisa qualitativa com entrevistas semiestruturadas, análise temática e revisão de literatura sobre formação docente e IA.",
  progress: 58,
  active: true,
  password: "pesquisa2026"
)
marina.save!

marina_orientation = professor.orientations.find_or_initialize_by(student: marina)
marina_orientation.assign_attributes(
  title: "Dissertação · Qualificação",
  status: "active",
  next_meeting_at: Time.current + 3.days,
  notes: "Acompanhamento da escrita, revisão do referencial e preparação para qualificação."
)
marina_orientation.save!

[
  [ "Revisar comentário da orientadora", Date.current + 1.day, "Responder à observação pendente no referencial teórico." ],
  [ "Conferir o checklist ABNT", Date.current + 3.days, "Revisar as sugestões antes de enviar a próxima versão." ],
  [ "Preparar pauta da reunião", Date.current + 5.days, "Separar dúvidas sobre o recorte e a análise dos dados." ]
].each do |title, due_on, description|
  task = marina_orientation.tasks.find_or_initialize_by(title: title)
  task.assign_attributes(due_on: due_on, description: description, status: "pending", source: "web")
  task.save!
end

meeting = marina_orientation.meetings.find_or_initialize_by(external_id: "seed-marina-orienta-01")
meeting.assign_attributes(
  held_at: Time.current - 2.days,
  title: "Teoria e categorias de análise",
  transcript: "Marina: Reorganizei as categorias e percebi que os textos falam da IA como apoio à prática, mas também levantam preocupações.\n#{professor.name}: Ótimo. Vamos separar as oportunidades pedagógicas das questões de autoria e formação.\nMarina: Posso relacionar essa discussão com o capítulo de formação docente.\n#{professor.name}: Sim. Na próxima versão, inclua uma transição entre esses dois eixos.",
  summary: "A conversa aprofundou a relação entre IA generativa, formação docente e práticas de ensino. A orientadora recomendou explicitar a ponte entre oportunidades pedagógicas e os desafios de autoria.",
  next_steps: "Revisar a seção sobre formação docente; conectar as categorias de análise aos objetivos; trazer uma nova versão para a próxima reunião.",
  source: "web"
)
meeting.save!

[
  [ "seed-marina-orienta-02", 8, "Delimitação do problema de pesquisa", "Marina: Ajustei a pergunta para olhar as práticas docentes no ensino superior.\n#{professor.name}: Esse recorte ficou mais claro. Traga a relação com a formação docente para o objetivo geral.", "A conversa delimitou o contexto do estudo e alinhou pergunta e objetivo geral.", "Revisar a redação dos objetivos específicos." ],
  [ "seed-marina-orienta-03", 15, "Estratégia para revisão de literatura", "Marina: Separei os textos de formação docente e os de inteligência artificial.\n#{professor.name}: Organize a síntese por conceitos, e não por resumo de autor.", "A orientadora sugeriu integrar os estudos por conceitos e registrar os critérios de busca.", "Criar uma matriz de síntese da literatura." ],
  [ "seed-marina-orienta-04", 22, "Plano de escrita da qualificação", "Marina: Gostaria de confirmar a ordem dos capítulos para a qualificação.\n#{professor.name}: Feche primeiro a pergunta, os objetivos e a metodologia; depois fazemos uma leitura completa.", "Foi definido um plano de escrita para fechar o texto de qualificação por etapas.", "Enviar a metodologia revisada antes de consolidar o documento completo." ]
].each do |external_id, days_ago, title, transcript, summary, next_steps|
  previous_meeting = marina_orientation.meetings.find_or_initialize_by(external_id: external_id)
  previous_meeting.assign_attributes(held_at: Time.current - days_ago.days, title: title, transcript: transcript, summary: summary, next_steps: next_steps, source: "web")
  previous_meeting.save!
end

works_data = [
  {
    title: "Capítulo 2 · Referencial teórico", category: "Capítulo 2", current_version: 3, status: "submitted",
    manuscript: "2.2 Inteligência artificial e formação docente\n\nA inserção da inteligência artificial no ensino superior amplia o debate sobre as competências necessárias à formação de professores. Para além do domínio instrumental, seu uso demanda reflexão sobre autoria, avaliação e os sentidos atribuídos ao trabalho docente.\n\nEstudos recentes apontam que ferramentas generativas podem apoiar o planejamento e a produção de materiais, desde que seu uso esteja acompanhado de critérios transparentes e mediação pedagógica. Nesse cenário, a formação continuada assume papel central para que docentes compreendam tanto as possibilidades quanto as limitações dessas tecnologias.\n\nA literatura também destaca a importância de práticas institucionais que promovam o uso crítico e responsável da IA. Mais do que definir ferramentas, torna-se necessário discutir como elas se articulam aos objetivos de aprendizagem e às relações construídas em sala de aula.",
    versions: [ [ 1, "Versão inicial", "Primeira organização do referencial", "approved" ], [ 2, "Revisão da orientadora", "Reorganização das seções e das categorias", "revision_requested" ], [ 3, "Revisada · atual", "Integração dos comentários sobre formação docente", "received" ] ]
  },
  {
    title: "Capítulo 3 · Metodologia", category: "Capítulo 3", current_version: 2, status: "draft",
    manuscript: "3 PROCEDIMENTOS METODOLÓGICOS\n\nEste capítulo apresenta a abordagem metodológica, o contexto da pesquisa e os procedimentos para produção e análise dos dados.\n\nA investigação adota abordagem qualitativa, adequada à compreensão das percepções e experiências dos participantes em seu contexto de atuação.",
    versions: [ [ 1, "Rascunho", "Estrutura inicial", "received" ], [ 2, "Em preparação", "Versão em elaboração", "received" ] ]
  },
  {
    title: "Dissertação completa", category: "Documento completo", current_version: 1, status: "draft",
    manuscript: "INTELIGÊNCIA ARTIFICIAL NA FORMAÇÃO DOCENTE\n\nDocumento de trabalho · versão de acompanhamento\n\nEste arquivo reúne os capítulos produzidos até o momento e serve como espaço de consolidação da pesquisa.",
    versions: [ [ 1, "Documento de trabalho", "Arquivo de consolidação", "received" ] ]
  }
]

works_data.each do |attributes|
  work = marina.academic_works.find_or_initialize_by(title: attributes[:title])
  work.assign_attributes(category: attributes[:category], status: attributes[:status], current_version: attributes[:current_version], manuscript: attributes[:manuscript], submitted_at: attributes[:status] == "submitted" ? Time.current - 5.days : nil)
  work.save!

  attributes[:versions].each do |number, label, change_note, version_status|
    version = work.work_versions.find_or_initialize_by(version_number: number)
    version.assign_attributes(label: label, change_note: change_note, status: version_status, uploaded_by: "student")
    version.save!
  end
end

referential = marina.academic_works.find_by!(title: "Capítulo 2 · Referencial teórico")
[
  [ "2.2 Inteligência artificial e formação docente", "A inserção da inteligência artificial no ensino superior amplia o debate", "Ampliar o conceito de formação docente", "open" ],
  [ "Conexão entre parágrafos", "Nesse cenário, a formação continuada assume papel central", "Explique como esse argumento se relaciona com o parágrafo anterior.", "resolved" ],
  [ "Recorte do estudo", "Estudos recentes apontam que ferramentas generativas", "Indique quais estudos sustentam esta afirmação e delimite o período analisado.", "resolved" ],
  [ "Definição de IA generativa", "ferramentas generativas podem apoiar o planejamento", "Boa definição. Manter a distinção entre ferramenta e prática pedagógica.", "resolved" ],
  [ "Síntese da seção", "A literatura também destaca a importância", "A síntese está clara; retomar os objetivos no fechamento do capítulo.", "resolved" ],
  [ "Coesão textual", "Nesse cenário, a formação continuada", "A transição entre as ideias está bem encaminhada.", "resolved" ],
  [ "Vocabulário acadêmico", "ferramentas generativas podem apoiar", "Evite generalizações; indique em quais condições esse apoio foi observado.", "resolved" ],
  [ "Articulação com a pesquisa", "a formação continuada assume papel central", "Relacione esse argumento ao contexto dos docentes participantes.", "resolved" ],
  [ "Organização da seção", "A literatura também destaca", "A sequência dos parágrafos está clara.", "resolved" ],
  [ "Citação e autoria", "Estudos recentes apontam", "Confira se a citação correspondente aparece na lista de referências.", "resolved" ],
  [ "Síntese crítica", "Mais do que definir ferramentas", "Boa síntese. Acrescente uma frase que conecte ao problema da pesquisa.", "resolved" ],
  [ "Revisão final", "práticas institucionais que promovam", "Revisado na versão anterior.", "resolved" ]
].each do |section, anchor, content, status|
  comment = referential.review_comments.find_or_initialize_by(section: section, anchor_text: anchor)
  comment.assign_attributes(content: content, author_name: "Profa. #{professor.name}", status: status)
  comment.save!
end

abnt_items = [
  [ "Estrutura do trabalho", "Elementos pré-textuais completos", "verified" ],
  [ "Estrutura do trabalho", "Capa e folha de rosto", "verified" ],
  [ "Estrutura do trabalho", "Resumo e palavras-chave", "verified" ],
  [ "Estrutura do trabalho", "Sumário corresponde aos títulos", "verified" ],
  [ "Formatação", "Margens do documento", "verified" ],
  [ "Formatação", "Fonte e tamanho do corpo do texto", "verified" ],
  [ "Formatação", "Espaçamento entre linhas", "verified" ],
  [ "Formatação", "Recuo de primeira linha", "verified" ],
  [ "Formatação", "Numeração progressiva das seções", "verified" ],
  [ "Formatação", "Paginação a partir da introdução", "verified" ],
  [ "Citações", "Citações diretas curtas", "verified" ],
  [ "Citações", "Citações diretas longas", "verified" ],
  [ "Citações", "Citações indiretas", "verified" ],
  [ "Citações", "Sistema autor-data consistente", "verified" ],
  [ "Referências", "Ordem alfabética", "verified" ],
  [ "Referências", "Alinhamento e espaçamento", "verified" ],
  [ "Referências", "Conferir DOI e endereço eletrônico", "suggestion" ],
  [ "Referências", "Padronizar destaque de títulos", "suggestion" ],
  [ "Citações", "Citação longa sem destaque de recuo", "suggestion" ],
  [ "Formatação", "Verificar títulos órfãos no fim da página", "suggestion" ],
  [ "Estrutura do trabalho", "Conferir lista de abreviaturas", "suggestion" ],
  [ "Referências", "Conferência manual de autoria institucional", "manual_review" ],
  [ "Citações", "Confirmar correspondência entre citação e referência", "manual_review" ],
  [ "Formatação", "Conferência visual das tabelas e figuras", "manual_review" ]
]

abnt_items.each_with_index do |(category, title, status), index|
  check = referential.abnt_checks.find_or_initialize_by(code: "ABNT-%02d" % (index + 1))
  check.assign_attributes(
    category: category,
    title: title,
    status: status,
    severity: status == "manual_review" ? "manual" : (status == "suggestion" ? "attention" : "ok"),
    excerpt: status == "suggestion" ? "Trecho identificado na versão 3 do capítulo." : nil,
    recommendation: status == "suggestion" ? "Revise este ponto no documento e confirme conforme as normas adotadas pelo programa." : nil,
    checked_at: status == "verified" ? Time.current - 1.day : nil
  )
  check.save!
end

[
  [ "Dossiê · IA na formação docente", "Periódico", "Revista Educação & Tecnologia", 76, 28.days.from_now.to_date, "Chamada temática sobre práticas, formação e tecnologias emergentes no ensino superior.", "O tema dialoga diretamente com o recorte sobre IA generativa e formação docente." ],
  [ "Congresso de Educação e Tecnologias", "Congresso", "Rede Educação Digital", 88, 42.days.from_now.to_date, "Submissões abertas para trabalhos completos e relatos de pesquisa em andamento.", "Prazo adequado para submeter um recorte do capítulo teórico como trabalho em andamento." ],
  [ "Seminário de Pesquisa em Formação Docente", "Evento", "PPG Educação · Encontro anual", 69, 60.days.from_now.to_date, "Encontro para compartilhar pesquisas de mestrado e doutorado em andamento.", "Pode ser uma boa oportunidade para receber comentários antes da qualificação." ]
].each do |title, item_type, organization, relevance, event_on, description, reason|
  opportunity = marina.opportunity_recommendations.find_or_initialize_by(title: title)
  opportunity.assign_attributes(item_type: item_type, organization: organization, subject: "Educação e tecnologias", relevance: relevance, event_on: event_on, deadline_on: event_on - 10.days, description: description, reason: reason, status: "recommended")
  opportunity.save!
end

puts "OrientaAI pronto: conta estudante marina.costa@orienta.demo / pesquisa2026; API docente cynara@produc.demo / produc2026."
