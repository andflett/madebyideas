class Notification < ActiveRecord::Base

  def queue_notification (action,controller,user_id,post_id,value)
    
    @existing_notification = Notification.find_by_sql(["SELECT * FROM notifications WHERE 
        user_id = ? and
        post_id = ? and
        action = ? and
        controller = ? and
        status = 'queued'",
        user_id,
        post_id,
        action,
        controller
    ])
    
    if @existing_notification.count == 0
      Notification.create(
        :action => action,
        :controller =>controller,
        :user_id => user_id,
        :post_id => post_id,
        :value => value,
        :status => 'queued'
      )
    else
      if @existing_notification.first.value != value
        @existing_notification.first.update_attribute(:value,value)
      end
    end
    
  end

  def deliver_queue
    @notifications = Notification.find_all_by_status('queued')
    @notifications.each do |notification|
      NotificationMailer.action_notification(notification).deliver
    end
  end
  
end