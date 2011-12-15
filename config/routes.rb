CsvImporter::Application.routes.draw do

  resources :attachments
  resources :imports do
    resources :data_rows
  end
  resources :data_rows

  match 'login' => 'sessions#create', :via => :post, :as => :login
  match 'login_success' => 'sessions#new', :via => :get, :as => :login_success
  match 'imports/upload' => 'imports#upload', :via => :post, :as => :upload_imports
  root :to => 'frontend#index'
end
