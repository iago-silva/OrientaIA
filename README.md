# OrientaAI

Portal Rails integrado de orientação acadêmica, baseado nos protótipos de professora e estudante. A IA apoia; a decisão de versão, escopo e publicação é humana.

## Ambiente local

Ruby 3.4.13, Bundler 4.0.6 e SQLite.

```sh
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/rails server -p 3100
```

Abra http://localhost:3100. As contas demonstrativas usam a senha `pesquisa2026`:

- Professora Helena: `helena@orienta.demo`
- Estudante Marina, formação concluída: `marina@orienta.demo`
- Estudante Lara, formação obrigatória pendente: `nova.aluna@orienta.demo`

Os dados são fictícios. `db:seed` é idempotente: não sobrescreve revisões e decisões existentes. Para descartar todos os dados do ambiente selecionado e recriar a demonstração, use explicitamente `bin/rails db:seed:replant`.

## Percursos implementados

- Painel docente, orientandos, agenda, reuniões e conversas humanas.
- Validação com comparação entre proposta original e versão editada, justificativa, conferência de fonte, contestação, rejeição e pedido de reprocessamento.
- Aprovação por item, confirmação da versão e quatro declarações obrigatórias. Alterar a revisão limpa a seleção. A publicação é transacional, com verificação da versão no servidor e trilha de auditoria.
- Alunos não recebem resumos, transcrições ou encaminhamentos antes da aprovação. Exportações seguem a mesma regra.
- Biblioteca de trabalhos com upload PDF/DOCX até 25 MB, classificação de sensibilidade, preservação de versões, download e comparação.
- Orientações publicadas, marcação de leitura e dúvidas à orientadora.
- Verificação ABNT demonstrativa, filtros, conferência humana e exportação do relatório.
- Agenda, conclusão de tarefas, oportunidades, busca, cadastro de chamadas e acompanhamento de recomendações demonstrativas.
- Áudio opcional das reuniões (MP3, M4A, WAV, OGG ou WebM, até 50 MB), com reprodução autenticada. Para o aluno, o áudio depende da publicação da transcrição.
- Consentimentos individuais de gravação, revogação para usos futuros e histórico persistido. Gravação não autoriza envio externo.
- Formação inicial em três etapas, prática validada no servidor e compromisso obrigatório. O acesso é bloqueado antes da conclusão.
- Guia de boas práticas, navegação por teclado e adaptação para telas menores.

O processamento de LLM não está conectado neste MVP, conforme os estados do protótipo. Solicitações são registradas como pendentes ou bloqueadas. Não há envio externo ou fallback automático, inclusive para dados sensíveis. As amostras demonstrativas não são resultados de inferência real nem certificação ABNT.

## API do assistente de voz

Todas as rotas `/api/v1` exigem `Authorization: Bearer <ROBOT_API_TOKEN>`. Em desenvolvimento o token padrão é `demo-robot-token`. Em produção, sem segredo a API recusa chamadas.

| Método | Rota | Uso |
| --- | --- | --- |
| GET | `/overview` | Resumo da orientação |
| GET / POST | `/students` | Consultar e cadastrar orientandos |
| GET / PATCH | `/students/:id` | Consultar e atualizar contexto |
| GET | `/orientations` | Orientações |
| GET / POST | `/orientations/:id/meetings` | Reuniões e propostas para revisão |
| GET / POST | `/orientations/:id/tasks` | Tarefas |
| PATCH | `/orientations/:orientation_id/tasks/:id` | Atualizar tarefa |
| GET / POST | `/orientations/:id/feedbacks` | Devolutivas para revisão |

O token do robô está vinculado à professora configurada por `ROBOT_PROFESSOR_EMAIL` (padrão da demonstração: `helena@orienta.demo`). Não existe endpoint de publicação pelo robô. As reuniões criadas pela API geram um prontuário privado pendente; `external_id` evita eventos duplicados.

Para anexar gravação, envie `meeting[audio_file]` junto aos demais campos em `multipart/form-data`. As reuniões de exemplo não contêm gravações reais.

## Railway

- Variáveis: `RAILS_ENV=production`, `SECRET_KEY_BASE` gerado por `bin/rails secret`, `ROBOT_API_TOKEN` aleatório.
- Uma instância e volume persistente em `/app/storage` para SQLite e anexos.
- Build: `SECRET_KEY_BASE_DUMMY=1 bundle exec rake assets:precompile` (dummy restrito a este comando; não configure essa variável globalmente).
- Start: `bin/start` prepara o banco e cria a nova demonstração apenas se ela ainda não existir.
- Para substituir dados antigos por esta demonstração, execute uma única vez `RAILS_ENV=production bin/rails db:seed:replant`. Isso descarta os dados do ambiente selecionado.
- Nunca publique `.env`, chaves, bancos locais, logs ou caches. Credenciais anteriormente expostas devem ser substituídas.

## Verificação

```sh
bin/rubocop
bin/brakeman --no-pager
bin/bundler-audit check --update
bin/rails db:test:prepare test
bin/rails test:system
```

Os testes cobrem navegação, ações dos formulários, isolamento entre orientações, formação, consentimentos, uploads, exportações, publicação e acesso ao conteúdo pendente. Os testes de navegador adicionais ficam em `test/system`.
