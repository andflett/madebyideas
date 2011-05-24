MadeByIdeas::Application.routes.draw do

  root :to => 'home#index'
  
  resources :comments
  devise_for :users, :controllers => { :registrations => "registrations" } 
  devise_for :user do
  end

  match "/posts/starred" => "posts#starred"
  resources :posts
  
  match "/rss" => "posts#index", :format => "rss"
  
  match "/home/:type" => "home#index"
  
  match "/posts/:id/favourite" => "posts#favourite"
  match "/posts/:id/rate/:rating" => "posts#rate"
  match "/posts/:id/claim" => "posts#claim"
  match "/posts/:id/flag" => "posts#toggle_flagged"
  match "/posts/:id/remove" => "posts#toggle_deleted"
  match "/posts/:id/complete/:status" => "posts#toggle_completed"
  match "/posts/user/:user" => "posts#index"

  match "/posts/tag/:tag" => "posts#index"
  
  match "/i:id" => "posts#show"
  match "about" => "about#index"

end