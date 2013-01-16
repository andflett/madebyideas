require File.join(File.dirname(__FILE__), '..', 'config', 'environment')
require 'net/imap'
require 'net/http'
require 'rubygems'

begin
  @notifications = Notification.new()
  @notifications.deliver_queue
end
