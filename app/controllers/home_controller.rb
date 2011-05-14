class HomeController < ApplicationController
  
  def index
    
    @posts = Post.paginate :page => params[:page], 
    :joins => "left join ratings r on posts.id = r.post_id", 
    :group => 'posts.id',
    :order => 'sum(r.value) DESC, posts.id DESC'

    respond_to do |format|
        format.html { render :layout => true }
        format.js { render :layout => false }  
    end
    
  end
  
end
