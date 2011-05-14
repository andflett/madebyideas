require File.join(File.dirname(__FILE__), '..', 'config', 'environment')
require 'net/imap'
require 'net/http'
require 'rubygems'

begin
  @posts = Post.new()
  @posts.publish_queue
end
