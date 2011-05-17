class NotificationMailer < ActionMailer::Base
  default :from => "made@byideas.co.uk"

  def action_notification(notification)

    @post = Post.find_by_id(notification.post_id)
    @owner = User.find_by_id(@post.user)
    @action_by = User.find_by_id(notification.user_id)

    unless @post.nil? or @owner.nil? or @action_by.nil?

      if (notification.controller == 'posts' and notification.action == 'toggle_flagged')
        @to = 'andrew@madebymany.co.uk'
      elsif(notification.controller == 'comments')
        if (@action_by.id == @owner.id && !@post.owner_id.nil?)
          @owner = User.find(@post.owner_id)
        end
        @to = @owner.email 
      elsif(notification.controller == 'posts' and notification.action == 'toggle_completed')
        if (@action_by.id == @owner.id && !@post.owner_id.nil?)
          @owner = User.find(@post.owner_id)
        end
        @to = @owner.email 
      elsif (notification.controller == 'posts')
        @to = @owner.email
      end

      @notification = notification
      mail(:to => @to, :subject => "Made by Ideas Notification")
      @notification.update_attribute(:status, 'sent')

    end

  end

end