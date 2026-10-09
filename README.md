# OrientaAI · MVP acadêmico

Aplicação Rails integrada para acompanhar uma pesquisa de pós-graduação. O espaço da estudante reúne painel da pesquisa, documentos e versões, comentários da orientadora, reuniões, agenda, oportunidades de submissão e uma análise ABNT assistida. O perfil docente continua disponível para gestão de orientandos e para a integração por API com o assistente de voz.

## Executar localmente

Requisitos: Ruby 3.4.3 e Bundler.

```sh
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/rails server
```

Abra `http://localhost:3000`.

**Demonstração do espaço de estudante**

- E-mail: `marina.costa@orienta.demo`
- Senha: `pesquisa2026`

**Demonstração do perfil docente / API do robô**

- E-mail: `cynara@produc.demo`
- Senha: `produc2026`
- Token local da API: `demo-robot-token`

Estudantes, textos, comentários, análises e oportunidades são dados fictícios para demonstração.

## Publicar uma demonstração no Railway

Para uma demonstração pequena com uma única instância, o app pode manter SQLite e Active Storage local; não precisa migrar para PostgreSQL agora.

1. Antes de enviar o repositório, confirme que `.gitignore` está aplicado e que `config/master.key` e os arquivos locais de `storage/` não estão versionados. Se uma chave já foi publicada em um remoto, substitua os segredos antes de usar o app online.
2. Crie um volume Railway para o serviço web com o ponto de montagem **`/app/storage`**. O banco SQLite de produção e os uploads do Active Storage ficam em `storage/`, então esse volume preserva ambos entre deploys.
3. Nas variáveis do serviço, configure `RAILS_ENV=production`, `SECRET_KEY_BASE` com um valor novo gerado por `bin/rails secret` e `ROBOT_API_TOKEN` com outro segredo aleatório. Não use `demo-robot-token` em produção. A tela da API mostra o token apenas localmente; em produção, informe o segredo ao cliente do robô por um canal separado.
4. Mantenha uma única instância enquanto o app usar SQLite em volume local.
5. Use como Start Command: `bin/rails db:prepare && bin/rails server -b ::`.

O primeiro `db:prepare` cria o banco e carrega os dados de demonstração. Nos deploys seguintes, ele preserva o banco existente e não reaplica as seeds. O volume é montado quando o serviço inicia; por isso, a preparação do banco deve ocorrer no Start Command.

**Atenção ao histórico do repositório:** `config/master.key`, `storage/development.sqlite3` e `storage/test.sqlite3` já aparecem no primeiro commit e no branch remoto `origin/main`. `.gitignore` impede novos arquivos ignorados de serem adicionados, mas não remove arquivos já versionados nem limpa commits antigos. Não publique outro deploy antes de remover esses arquivos do controle de versão e substituir qualquer segredo que possa ter sido exposto. A remoção do histórico remoto exige reescrita do histórico e atualização forçada do branch.

## O que funciona no protótipo

- Painel da pesquisa com etapas, trabalhos recentes, tarefas e próximas orientações.
- Biblioteca de trabalhos, histórico de versões e envio de PDF/DOCX por Active Storage.
- Leitura de prévia textual com comentários da orientadora; a estudante pode responder e marcar comentários como revisados.
- Registros de reuniões com transcrição, resumo, encaminhamentos e anexo opcional de áudio.
- Agenda com tarefas que podem ser concluídas.
- Recomendações demonstrativas de periódicos e eventos que a estudante pode acompanhar.
- Checklist ABNT com sugestões e pontos que exigem conferência humana.
- Perfil docente com estudantes/orientações e API REST autenticada para o robô.

## API para o robô

Todas as rotas ficam sob `/api/v1` e exigem `Authorization: Bearer <token>`. Em desenvolvimento, o token padrão é `demo-robot-token`. Configure `ROBOT_API_TOKEN` no ambiente para definir outro token. Em produção, a API falha de forma fechada quando o segredo não foi configurado.

| Método | Rota | Uso |
| --- | --- | --- |
| GET | `/api/v1/overview` | Resumo do painel e próximas orientações |
| GET | `/api/v1/students` | Lista de estudantes; filtro `?active=true` |
| GET | `/api/v1/students/:id` | Dados e contexto de pesquisa |
| POST | `/api/v1/students` | Cadastrar estudante |
| PATCH | `/api/v1/students/:id` | Atualizar estudante |
| GET | `/api/v1/orientations` | Lista; filtro `?status=active` |
| GET | `/api/v1/orientations/:id` | Detalhe da orientação |
| GET / POST | `/api/v1/orientations/:id/meetings` | Consultar ou registrar encontro |
| GET / POST | `/api/v1/orientations/:id/tasks` | Consultar ou criar tarefa |
| PATCH | `/api/v1/orientations/:orientation_id/tasks/:task_id` | Atualizar tarefa |
| GET / POST | `/api/v1/orientations/:id/feedbacks` | Consultar ou registrar feedback |

Exemplo para salvar uma reunião:

```sh
curl -X POST http://localhost:3000/api/v1/orientations/1/meetings \
  -H 'Authorization: Bearer demo-robot-token' \
  -H 'Content-Type: application/json' \
  -d '{"meeting":{"held_at":"2026-10-07T14:00:00-03:00","title":"Alinhamento da metodologia","transcript":"Transcrição reconhecida pelo robô...","summary":"Definimos os critérios de seleção.","next_steps":"Enviar a versão revisada até sexta-feira.","external_id":"gravacao-001"}}'
```

O campo `external_id` identifica uma gravação externa e é único dentro de cada orientação. Registros recebidos pela API ficam marcados com `source: "robot"`; os criados pela interface ficam como `source: "web"`.

## Limites do MVP

O painel ABNT, os resumos e as recomendações são exemplos estáticos de demonstração; não há LLM conectado nem validação normativa real. A prévia do trabalho também é um texto demonstrativo até a estudante enviar seu documento. A captura de voz e a geração de transcrição/resumo pelo robô pertencem à integração do outro TCC. O token local é compartilhado e serve apenas para desenvolvimento/demonstração.
