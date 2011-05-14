class NotificationMailer < ActionMailer::Base
  default :from => "made@byideas.co.uk"
  
  def action_notification(notification)
    
    @post = Post.find(notification.post_id)
    @owner = User.find(@post.user)

    @started_by = User.find(notification.user_id)
    
    if (notification.controller == 'posts')
      @to = @owner.email
    elsif(notification.controller == 'comments')
      if (@started_by.id == @owner.id && !@post.owner_id.nil?)
        @to = User.find(@post.owner_id).email 
      else
        @to = @owner.email 
      end
    end
    
    @notification = notification
    mail(:to => @to, :subject => "Made by Ideas Notification")
    
    @notification.update_attribute(:status, 'sent')
    
  end

end