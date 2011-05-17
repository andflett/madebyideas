class CommentsController < ApplicationController
  before_filter :authenticate_user!, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :fetch_comment, :only => [:update, :edit, :show, :destroy]
  before_filter :authorise_as_owner, :only => [:edit, :update, :destroy]
  
  def authorise_as_owner
    unless @comment.user.id == current_user.id
      flash[:alert]  = "You can't edit other people's comments"
      redirect_to("#{posts_path}/#{@comment.post.id}")
    end
  end
  
  def fetch_comment
  	@comment = Comment.find(params[:id])
  end

  def edit
    @post = @comment.post
  end

  def create
    
    if params[:private]=="false"
      params[:private] = false
    else
      params[:private] = true
    end
    
    @comment = Comment.new(params[:comment])
    @comment.user = current_user
    @notifications = Notification.new()

    respond_to do |format|
      if @comment.save
         @notifications.queue_notification(action_name,controller_name,current_user.id,@comment.post.id,@comment.comment)
         if request.xhr?
            format.js { render :layout => false }  
          else
            format.html { render :layout => true }
          end
      else
        format.html { redirect_to(post_path(@comment.post)+"#new_comment") }
      end
    end
  end

  def update
    @comment = Comment.find(params[:id])
    @comment.user = current_user
    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        format.html { redirect_to(post_path(@comment.post)+"#comment-#{@comment.id}") }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to(post_path(@comment.post)) }
    end
  end
  
end
