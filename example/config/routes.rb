Rails.application.routes.draw do
  constraints ->(req) { req.host.start_with?("blog") } do
    namespace :docs do
      namespace :api do
        resources :houses
      end
    end
  end
end
