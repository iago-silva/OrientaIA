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

  resources :academic_works, path: "trabalhos", only: %i[index show] do
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
end
