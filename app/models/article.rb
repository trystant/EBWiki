# This is still called "Article", although its true name is "Case"
# TODO: Rename this to Case
#
class Article < ActiveRecord::Base
  # TODO: Clean up relationship section
  belongs_to :user
  belongs_to :category
  belongs_to :state
  has_many :links
  accepts_nested_attributes_for :links, :reject_if => :all_blank, :allow_destroy => true
  has_many :comments, as: :commentable, :dependent => :destroy
  has_many :subjects
  accepts_nested_attributes_for :subjects, :reject_if => :all_blank, :allow_destroy => true
  has_many :hashtags
  accepts_nested_attributes_for :hashtags, :reject_if => :all_blank, :allow_destroy => true

  # Paper Trail
  has_paper_trail
  # Acts as Follows, for follower functionality
  acts_as_followable

  # Friendly ID
  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]

  # Elasticsearch Gem
  searchkick


  # Model Validations
  validates :date, presence: { message: "Please add a date." }
  validate :article_date_cannot_be_in_the_future
  validates :city, presence: { message: "Please add a city." }
  validates :state_id, presence: { message: "Please specify the state where this incident occurred before saving." }
  validates :title, presence: { message: "Please specify a title"}
  # Avatar uploader using carrierwave
  mount_uploader :avatar, AvatarUploader

  # Geocoding articles
  geocoded_by :full_address   # can also be an IP address
  after_validation :geocode          # auto-fetch coordinates


  # Scopes
  scope :by_state, -> (state_id) {where(state_id: state_id)}

  def full_address
    "#{address} #{city} #{state} #{zipcode}"
  end

  def self.find_by_search(query)
    search(query)
  end

  def nearby_cases
    self.try(:nearbys, 50).try(:order, "distance")
    #self.nearbys(50).order("distance")
  end

  def article_date_cannot_be_in_the_future
    if date.present? && date > Date.today
      errors.add(:date, "must be in the past")
    end
  end

  # Try building a slug based on the following fields in
  # increasing order of specificity.
  def slug_candidates
    [
      :title,
      [:title, :city],
      [:title, :city, :zipcode]
    ]
  end

  def twitter_time_to_reset
    (Time.at($client.get('/1.1/application/rate_limit_status.json')[:resources][:search][:"/search/tweets"][:reset]) - Time.now).round
  end

  def twitter_remaining
    $client.get('/1.1/application/rate_limit_status.json')[:resources][:search][:"/search/tweets"][:remaining]
  end

  def tweets
    if self.twitter_remaining > 0
      unless self.hashtags.empty?
        tweets = []
        self.hashtags.each do |tag|
          $client.search("#{tag.letters} -rt", :result_type => "recent", lang: "en").take(10).each do |tweet|
            tweets << tweet
          end
        end
        begin
          tweets.to_a
        rescue Twitter::Error::TooManyRequests => error
          # NOTE: Your process could go to sleep for up to 15 minutes but if you
          # retry any sooner, it will almost certainly fail with the same exception.
          sleep error.rate_limit.reset_in + 1
          retry
        end

      return tweets.sort_by(&:created_at).reverse
      end
    else
      return "Waiting for Twitter API limit to reset in #{self.twitter_time_to_reset} seconds"
    end
  end
end
