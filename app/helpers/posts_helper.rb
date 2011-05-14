module PostsHelper
  def current_user_rating(id)
      if @rating = current_user.ratings.find_by_post_id(id)
          @rating.value
      else
          false
      end
  end
end
