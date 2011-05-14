class PostsController < ApplicationController
  before_filter :authenticate_user!, :only => [:new, :create, :edit, :update, :destroy, :rate, :claim]
  before_filter :fetch_post, :only => [:edit, :update, :destroy]
  before_filter :authorise_as_owner, :only => [:edit, :update, :destroy]
     
  @@return_early = Proc.new do 
    render :json => {:status => 0, :message => "Error"}.to_json
    return false
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found');
  end

  def fetch_post 
  	@post = Post.find(params[:id])
  end

  def authorise_as_owner
    unless @post.user.id == current_user.id
      flash[:alert]  = "Shame on you - don't try to edit other people's ideas."
      redirect_to("#{posts_path}/#{@post.id}")
    end
  end
   
  def index
    
  	if params[:user]
  	  @user = User.find(params[:user])
  	  @conditions = ['users_id=?',"#{Integer(params[:user])}"]
  	elsif params[:tag]
  	   @tag = params[:tag]
       @conditions = ['lower(title) LIKE ?',"%##{params[:tag].downcase}%"]
  	elsif current_user
  	  @conditions = ['users_id=?',"#{current_user.id}"]
    end
    
    @posts = Post.paginate :page => params[:page], 
    :conditions => @conditions,
    :joins => "left join ratings r on posts.id = r.post_id", 
    :group => 'posts.id',
    :order => 'sum(r.value) DESC, posts.id DESC'
    
    if @posts.count == 0 and @user and current_user
      if current_user.id == @user.id
        @post = Post.new
        render :new, :layout => true
      end
    else 
        respond_to do |format|
            format.html { render :layout => true }
            format.js { render :layout => false }  
        end
    end
    
  end
  
  def show
    @post = Post.find(params[:id])
    @new_comment = Comment.new
    
    unless @post.owner_id.nil?
      @owner = User.find(@post.owner_id)
    end
    
    respond_to do |format|
        format.html { render :layout => true }
        format.js { render :layout => false }  
    end
  end
  
  def new
    @post = Post.new
    respond_to do |format|
        if request.xhr?
            format.js { render :layout => false }  
        else
           format.html { render :layout => true }
        end
  	end
  end

  def create
    @post = Post.new(params[:post])
    @post.user = current_user
    Post.transaction do
      respond_to do |format|
        if @post.save
            format.json { render :json => {:id=> @post.id, :name => @post.photo.name} }
            format.html { redirect_to(root_path, :notice => "Thanks for donating your idea.") }
        else
          if request.xhr?
              format.js { render :action => :new, :layout => false }  
          else
             format.html { render :action => :new, :layout => true }
          end
        end
      end
    end
  end
  
  def edit
    @post = Post.find(params[:id])
  end
  
  def update
   @post = Post.find(params[:id])
   @post.user = current_user
   	 respond_to do |format|
	    if @post.update_attributes(params[:post])
	      	format.json { render :json => {:id=> @post.id, :name => @post.photo.name} }
	        format.html { redirect_to("#{root_path}#idea-#{@post.id}") }
	    else
	      render :action => 'edit'
	    end
	  end
  end
  
  def flag
    @post = Post.find(params[:id])
    
    if @post.status == 'open'
      @post.update_attribute(:status, 'owned')
      @post.save
    elsif @post.status == 'owned'
      @post.update_attribute(:status, 'open')
      @post.save
    end
        
    respond_to do |format|
      format.js { render :layout => false }
    end
  end
  
  def hide
    @post = Post.find(params[:id])
    
    if @post.status == 'open'
      @post.update_attribute(:status, 'owned')
      @post.save
    elsif @post.status == 'owned'
      @post.update_attribute(:status, 'open')
      @post.save
    end
        
    respond_to do |format|
      format.js { render :layout => false }
    end
  end
  
  def update
   @post = Post.find(params[:id])
   @post.user = current_user
   	 respond_to do |format|
	    if @post.update_attributes(params[:post])
	      	format.json { render :json => {:id=> @post.id, :name => @post.photo.name} }
	        format.html { redirect_to("#{root_path}#idea-#{@post.id}") }
	    else
	      render :action => 'edit'
	    end
	  end
  end
  
  def rate
    @post = Post.find(params[:id])
    if @rating = current_user.ratings.find_by_post_id(params[:id])
      @rating.update_attribute(:value, params[:rating].to_i)
    else
      @rating = Rating.new()
      @rating.post_id = @post.id
      @rating.user_id = current_user.id
      @rating.value = params[:rating].to_i
      @rating.save
    end
    respond_to do |format|
      format.js { render :layout => false }
    end
  end
  
  def claim
    @post = Post.find(params[:id])
    @post_claimed = Post.find_by_owner_id(current_user.id)
    @notifications = Notification.new()
    
    if !@post_claimed.nil? and params[:confirm].nil? and @post.status == 'open'
      respond_to do |format|
        format.js { render :layout => false, :action => 'claim_confirmation' }
      end
      return
    end
    
    if @post.status == 'open'
      @post.update_attribute(:status, 'owned')
      @post.update_attribute(:owner_id, current_user.id)
      @post.save
      @owner = User.find(@post.owner_id)
      unless @post_claimed.nil?
        @post_claimed.update_attribute(:status, 'open')
        @post_claimed.update_attribute(:owner_id, nil)
        @post_claimed.save
        @notifications.queue_notification(action_name,controller_name,current_user.id,@post_claimed.id,@post_claimed.status)
      end
    elsif @post.status == 'owned'
      @post.update_attribute(:status, 'open')
      @post.update_attribute(:owner_id, nil)
      @post.save
    end
    
    @notifications.queue_notification(action_name,controller_name,current_user.id,@post.id,@post.status)
    
    respond_to do |format|
      format.js { render :layout => false }
    end
    
  end
    
  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to(posts_path, :notice => 'Away it goes, never to return.')
  end

private
 
end