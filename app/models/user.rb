class User < ActiveRecord::Base
  # To use devise-twitter don't forget to include the :twitter_oauth module:
  # e.g. devise :database_authenticatable, ... , :twitter_oauth

  # IMPORTANT: If you want to support sign in via twitter you MUST remove the
  #            :validatable module, otherwise the user will never be saved
  #            since it's email and password is blank.
  #            :validatable checks only email and password so it's safe to remove

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  attr_accessor :login
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :login, :twitter_handle, :append_twitter_handle
  
  has_many :posts, :dependent => :destroy, :foreign_key => "posts_id"
  has_many :ratings, :dependent => :destroy
  has_many :favourites, :dependent => :destroy
  has_many :rated_posts, :through => :ratings, :source => :posts
  has_many :comments, :dependent => :destroy, :foreign_key => "users_id"

  validates :username, :presence => true, :uniqueness => true
  
  def password_required?
    new_record?
  end
  
  protected

   def self.find_for_database_authentication(warden_conditions)
     conditions = warden_conditions.dup
     login = conditions.delete(:login)
     where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
   end
  
end
