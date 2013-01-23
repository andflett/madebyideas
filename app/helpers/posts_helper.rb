module PostsHelper
  
  def current_user_rating(id)
      if @rating = current_user.ratings.find_by_post_id(id)
          @rating.value
      else
          false
      end
  end
  
  def can_view_private_conversation
    current_user and (current_user.id == @post.users_id or current_user.id == @post.owner_id)
  end
  
	# So we can render the devise form from the post controller
	def resource_name
	    :user
	end

	def resource
	  @resource ||= User.new
	end

	def devise_mapping
		@devise_mapping ||= Devise.mappings[:user]
	end

end
