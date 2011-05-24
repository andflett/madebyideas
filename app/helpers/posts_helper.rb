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
  
end
