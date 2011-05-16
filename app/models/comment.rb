class Comment < ActiveRecord::Base
   belongs_to :user, :foreign_key => "users_id"
   belongs_to :post, :foreign_key => "posts_id"
   
   validates_presence_of :comment
   validate :throttle_posts

   def throttle_posts
     @transactions = Comment.find_by_sql(["SELECT * FROM comments WHERE 
                     users_id = ? and
                     created_at < ? and
                     created_at > ?",
                     user.id,
                     Time.now,
                     2.minutes.ago
     ])
     if @transactions.count > 10
       errors[:base] << "You've published too many comments recently, try again in a few minutes."
     end
   end
   
end
