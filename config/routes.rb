MadeByIdeas::Application.routes.draw do

  resources :comments

  devise_for :users, :controllers => { :registrations => "registrations" } 

  devise_for :user do
  end

  get "home/index"

  resources :posts
  
  match "/posts/:id/rate/:rating" => "posts#rate"
  match "/posts/:id/claim" => "posts#claim"
  match "/posts/user/:user" => "posts#index"
  match "/posts/tag/:tag" => "posts#index"
  match "/i:id" => "posts#show"
  match "about" => "about#index"
 
  root :to => 'home#index'

end