Rails.application.routes.draw do
  root "dashboard#index"

  get "/login", to: "sessions#new", as: :login
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy", as: :logout
  get "/cadastro", to: "registrations#new", as: :signup
  post "/cadastro", to: "registrations#create"

  resources :students
  resources :orientations, only: %i[index show update] do
    resources :meetings, only: :create
    resources :tasks, only: %i[create update]
    resources :feedbacks, only: :create
  end
  get "/assistente", to: "assistant#show", as: :assistant
  get "/validacao", to: "supervision#index", as: :supervision
  get "/validacao/:id", to: "supervision#show", as: :review_record
  patch "/validacao/:id", to: "supervision#update"
  get "/validacao/:id/decisao", to: "supervision#decision", as: :review_decision
  get "/validacao/:id/supervisao", to: "supervision#flow", as: :supervision_flow
  get "/validacao/:id/historico", to: "supervision#trail", as: :review_trail
  get "/privacidade", to: "privacy#show", as: :privacy
  post "/consentimentos", to: "privacy#update", as: :consents
  get "/formacao", to: "training#show", as: :training
  patch "/formacao", to: "training#update"
  get "/boas-praticas", to: "guides#show", as: :guide
  get "/professor/reunioes", to: "professor_meetings#index", as: :professor_meetings
  post "/mensagens", to: "orientation_messages#create", as: :orientation_messages
  get "/reunioes/:id/exportar", to: "student_meetings#export", as: :export_meeting
  get "/reunioes/:id/audio", to: "meeting_media#show", as: :meeting_audio
  get "/trabalhos/:id/exportar", to: "academic_works#export", as: :export_work
  get "/trabalhos/:id/versoes/:version_id/download", to: "academic_works#download", as: :download_version
  get "/trabalhos/:id/comparar", to: "academic_works#compare", as: :compare_work
  get "/analise-abnt/exportar", to: "abnt_analyses#export", as: :export_abnt
  resources :opportunities, path: "chamadas", only: %i[new create show]
  post "/submissoes/:id/recomendar", to: "opportunity_recommendations#recommend", as: :recommend_opportunity
  post "/submissoes/:id/ciencia", to: "opportunity_recommendations#acknowledge", as: :acknowledge_opportunity
  post "/processamentos", to: "processing_requests#create", as: :processing_requests

  resources :academic_works, path: "trabalhos", only: %i[index show create] do
    resources :work_versions, only: :create
    resources :review_comments, only: %i[create update]
  end
  get "/analise-abnt", to: "abnt_analyses#show", as: :abnt_analysis
  resources :abnt_checks, only: :update
  get "/agenda", to: "student_agenda#index", as: :student_agenda
  resources :student_meetings, path: "reunioes", only: %i[index create]
  resources :opportunity_recommendations, path: "submissoes", only: %i[index update]
  resources :student_tasks, path: "tarefas", only: :update

  namespace :api do
    namespace :v1 do
      get "overview", to: "overview#show"
      resources :students, only: %i[index show create update]
      resources :orientations, only: %i[index show] do
        resources :meetings, only: %i[index create]
        resources :tasks, only: %i[index create update]
        resources :feedbacks, only: %i[index create]
      end
    end
  end
  get "/up", to: "rails/health#show", as: :rails_health_check
end
