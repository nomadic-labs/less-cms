Rails.application.routes.draw do
  resources :websites
  post 'websites/:id/deploy', to: 'websites#deploy', as: "deploy_website"
end
