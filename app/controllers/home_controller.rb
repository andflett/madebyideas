class HomeController < ApplicationController
  
  def index
    
    if params[:type] == 'complete'
      @conditions = ["deleted = false and completed = true"]
    elsif params[:type] == 'progress'
      @conditions = ["deleted = false and completed = false and status = 'owned'"]
    else
      @conditions = ["deleted = false and completed = false and status = 'open'"]
    end
    
    @posts = Post.paginate :page => params[:page],
    :conditions => @conditions,
		:select => "posts.*, sum(r.value) as rate",
    :joins => "left outer join ratings r on posts.id = r.post_id", 
    :group => 'posts.id',
    :order => 'rate DESC, posts.id DESC'

    respond_to do |format|
        format.html { render :layout => true }
        format.js { render :layout => false }  
    end
    
  end
  
end
