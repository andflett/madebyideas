class PostsController < ApplicationController
  before_filter :authenticate_user!, :only => [:create, :edit, :update, :destroy, :rate, :claim, :toggle_flagged, :toggle_deleted, :starred, :favourite]
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
  
  def can_view_private_conversation
    current_user and (current_user.id == @post.users_id or current_user.id == @post.owner_id)
  end
   
  def index
    
  	if params[:user]
  	  @user = User.find(params[:user])
  	  @conditions = ['users_id=? and deleted = false',"#{Integer(params[:user])}"]
    elsif params[:f_user]
    	@user = User.find(params[:f_user])
    	@conditions = ['users_id=? and deleted = false and count(f) > 0',"#{Integer(params[:user])}"]
  	elsif params[:tag]
  	   @tag = params[:tag]
       @conditions = ['lower(title) LIKE ? and deleted = false',"%##{params[:tag].downcase}%"]
  	elsif current_user
  	  @conditions = ['users_id=? and deleted = false',"#{current_user.id}"]
    end

    @posts = Post.paginate :page => params[:page], 
    :conditions => @conditions,
    :select => "posts.*, sum(r.value) as rate",
    :joins => "left outer join ratings r on posts.id = r.post_id left join favourites f on posts.id = f.post_id", 
    :group => 'posts.id',
    :order => 'rate DESC NULLS LAST, posts.id DESC'
    
    if @posts.count == 0 and @user and current_user
      if current_user.id == @user.id
        @post = Post.new
        render :new, :layout => true
      end
    else 
        respond_to do |format|
            format.html { render :layout => true }
            format.js { render :layout => false }
            format.rss { 
              @posts = Post.all(:order => 'created_at desc')
              render :layout => false 
            } 
        end
    end
    
  end
  
  def starred
    
  	@user = User.find(current_user.id)
    @favourites = Favourite.find_all_by_user_id(current_user.id, :order => "updated_at desc")
  
    respond_to do |format|
        format.html { render :layout => true }
        format.js { render :layout => false }
    end

  end
  
  def show
    @post = Post.find_by_id_and_deleted(params[:id],false)
    @new_comment = Comment.new
    
    if @post.nil?
      render 'about/error_404' 
      return
    end
    
    unless @post.owner_id.nil?
      @owner = User.find(@post.owner_id)
    end
    
    @public_comments = Comment.find_by_posts_id_and_private(@post.id,false)
    
    respond_to do |format|
        format.html { render :layout => true }
        format.js { render :layout => false }  
    end
  end
  
  def new
	
		if user_signed_in?
    	@post = Post.new
	    respond_to do |format|
	        if request.xhr?
	            format.js { render :layout => false }  
	        else
	           format.html { render :layout => true }
	        end
	  	end
		else
			respond_to do |format|
	        if request.xhr?
	           format.js { render  "devise/sessions/new", :layout => false }  
	        else
	           authenticate_user!
	        end
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
  
  def toggle_flagged
    
    @post = Post.find(params[:id])
    @notifications = Notification.new()
    
    if @post.flagged == true && current_user.admin
      @post.update_attribute(:flagged, false)
      @post.save
    elsif @post.flagged == false
      @post.update_attribute(:flagged, true)
      @post.save
      @notifications.queue_notification(
        action_name,
        controller_name,
        current_user.id,
        @post.id,
        @post.flagged
      )
    end
        
    respond_to do |format|
      format.js { render :layout => false }
    end
    
  end
  
  def toggle_deleted
    
    @post = Post.find(params[:id])
    
    if current_user.admin
      if @post.deleted == true
        @post.update_attribute(:deleted, false)
        @post.save
        redirect_to root_path
      elsif @post.deleted == false
        @post.update_attribute(:deleted, true)
        @post.update_attribute(:owner_id, nil)
        @post.update_attribute(:status, 'open')
        @post.save
        respond_to do |format|
          format.js { render :layout => false }
        end
      end
    end
    
  end
  
  def toggle_completed
    
    @notifications = Notification.new();
    @post = Post.find(params[:id])
    
    if can_view_private_conversation
    
      if params[:status] == '0'
        @post.update_attribute(:completed, false)
        @post.update_attribute(:completed_by, nil)
        @post.save
      elsif params[:status] == '1'
        @post.update_attribute(:completed, true)
        @post.update_attribute(:completed_by, current_user.id)
        @post.save
      end
    
      @notifications.queue_notification(
        action_name,
        controller_name,
        current_user.id,
        @post.id,
        @post.completed
      )
    
    end
    
    respond_to do |format|
      format.js { render :layout => false }
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
  
  def favourite
    @post = Post.find(params[:id])
    if @favourite = current_user.favourites.find_by_post_id(params[:id])
      @favourite.destroy
      @favourited = false
    else
      @favourite = Favourite.new()
      @favourite.post_id = @post.id
      @favourite.user_id = current_user.id
      @favourite.save
      @favourited = true
    end
    respond_to do |format|
      format.js { render :layout => false }
    end
  end
  
  def claim
    @post = Post.find_by_id_and_deleted(params[:id],false)
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
        unless @post_claimed.completed and @post_claimed.status == 'open'
          @notifications.queue_notification(action_name,controller_name,current_user.id,@post_claimed.id,@post_claimed.status)
        end
      end
    elsif @post.status == 'owned'
      @post.update_attribute(:status, 'open')
      @post.update_attribute(:owner_id, nil)
      @post.save
    end
    
    unless @post.completed and @post.status == 'open'
      @notifications.queue_notification(action_name,controller_name,current_user.id,@post.id,@post.status)
    end
    
    respond_to do |format|
      format.js { render :layout => false }
    end
    
  end
    
  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    respond_to do |format|
      format.js { render :layout => false }
      format.html { redirect_to(posts_path, :notice => 'Away it goes, never to return.') }
    end
    
  end

private
 
end