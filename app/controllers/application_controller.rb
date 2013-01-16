class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :all
  
  def after_sign_in_path_for(resource)
    params[:next] || super
  end
  
end