class Post < ActiveRecord::Base
  cattr_reader :per_page
  @@per_page = 20
  
  belongs_to :user, :foreign_key => "users_id"
  has_many :ratings
  has_many :comments, :foreign_key => "posts_id", :order => "created_at DESC"
  has_many :raters, :through => :ratings, :source => :users
  
  validates_presence_of :title, :message => "error: You've not told us anything about your idea"
  validates_length_of :title, :maximum => 90, :message => "Try to keep your idea to under 90 characters."
  validate :throttle_posts
    
  require 'bitly'

  def truncate(text, options = {})
    options.reverse_merge!(:length => 30)
    text.truncate(options.delete(:length), options) if text
  end
  
  def publish 
    
    client = TwitterOAuth::Client.new(
        :consumer_key => 'hSawBbreaRcDM0IWA03sA',
        :consumer_secret => 'JchYZzzvbCEdHOKQrT3IxumblZFxOiPNV53jwShU',
        :token => '292960750-idfUcK4S2qtNbtUGrN97FhktR3YsFlU0soWENPR3',
        :secret => '6JvMz8y9hIYDOvpox6BLqgWB8GfdCJoaVm5xrfRm0'
    )

    @short_title = truncate(self.title,:length => 90)
    bitly = Bitly.new('madebyideas','R_43befe59f7f836397f08ab3c5c5bbf90')
    page_url = bitly.shorten("http://byideas.co.uk/i#{self.id}",:history => 1)

    #client.update("Idea: #{@short_title} #{page_url.shorten}")
    
    self.update_attribute(:published, true)
    
  end
  
  def publish_queue
    @posts = Post.find_all_by_published(false)
    @posts.each do |post|
      post.publish
    end
  end
  
  def throttle_posts
    @transactions = Post.find_by_sql(["SELECT * FROM posts WHERE 
                    users_id = ? and
                    created_at < ? and
                    created_at > ?",
                    user.id,
                    Time.now,
                    5.minutes.ago
    ])
    if @transactions.count > 3
      errors[:base] << "You've published too many ideas recently, try again in a few minutes."
    end
  end
  
  def total_rating
      @value = 0
      self.ratings.each do |rating|
          @value = @value + rating.value
      end
      @total = @value
  end
  
end
