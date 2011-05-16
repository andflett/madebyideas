class Emailer < ActionMailer::Base

  def truncate(text, options = {})
    options.reverse_merge!(:length => 30)
    text.truncate(options.delete(:length), options) if text
  end

 def receive(mail)
  
   unless user = User.find_by_email(mail.from)
     #puts 'Checking against auto-registration whitelist'
     email = mail.from.to_s.match /(.+)@(.+)/
     if email[2] == 'madebymany.co.uk' or email[2] == 'angryrobotzombie.com'
       #puts 'Creating new user account'
       password = User.generate_token('encrypted_password')
       #puts 'Registering user'
       user = User.new(:email=>mail.from, :username => email[1], :password => password, :password_confirmation => password)
       user.save
       #puts 'Send password reset instructions'
       user.send_reset_password_instructions
     end
   end
   
   if mail.multipart?
      body = ActiveSupport::Multibyte::clean(mail.parts[0].body.decoded)
    else
      body = ActiveSupport::Multibyte::clean(mail.body.decoded)
    end
   
   if user.nil?
     puts 'No user exists with that email address'
   else 
       @post = user.posts.create!(
         :title => truncate(mail.subject,:length => 90),
         :body => body,
         :users_id => user.id
       )
       puts 'Posting'
  end
  
 end

end