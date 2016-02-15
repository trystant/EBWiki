require 'observer'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :articles
  has_many :comments
  geocoded_by :current_sign_in_ip   # can also be a street address
  before_save :geocode  # auto-fetch coordinates when user logs in
  acts_as_follower
  acts_as_messageable
  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]
  after_validation :add_to_mailchimp
 
  def mailboxer_name
    self.name
  end
 
  def mailboxer_email(object)
    self.email
  end

  def slug_candidates
    [
      :name,
      [:name, :id]
    ]
  end

  def add_to_mailchimp
    gb = Gibbon::Request.new(api_key: ENV['MAILCHIMP_API_KEY'])
    if self.subscribed? # if the user has checked the "subscribed" checkbox
      if self.mailchimp_status.present? # if MailChimp recognizes the email address
        gb.lists(ENV['MAILCHIMP_LIST_ID']).members(Digest::MD5.hexdigest("#{self.email.downcase}")).update(body: { status: "subscribed" }) #subscribe user 
      elsif self.mailchimp_status.nil? # if MailChimp doesn't have a user for the email address
        gb.lists(ENV['MAILCHIMP_LIST_ID']).members.create(body: { # create a MailChimp pending subscriber
          email_address: "#{self.email}",
          status: "pending", # setting this to 'subscribed' will remove double optin
          merge_fields: {FNAME: "#{self.name}"}
          })
      end
    # unsubscribe user if box is unchecked but mailchimp has user as subscribed or pending
    else
      unless self.mailchimp_user.kind_of?(Array)
        gb.lists(ENV['MAILCHIMP_LIST_ID']).members(self.mailchimp_member_id).update(body: { status: "unsubscribed" })  
      end
    end
  end

# -------- Previous code
  # returns the mailchimp member if one exists for @user.email
  def mailchimp_user
    gb = Gibbon::Request.new
    gb.lists(ENV['MAILCHIMP_LIST_ID']).members(Digest::MD5.hexdigest("#{self.email.downcase}")).retrieve
    rescue Gibbon::MailChimpError => e
    return nil, :flash => { error: e.message }
  end
  
  # returns mailchimp member id for users registered with MC
  def mailchimp_member_id
    if self.mailchimp_user.kind_of?(Array)
      return nil
    elsif self.mailchimp_user.kind_of?(Hash)
      self.mailchimp_user["id"]
    end
  end

  # # returns the mailChimp status of the user  
  def mailchimp_status
    if self.mailchimp_user.kind_of?(Array)
      return nil
    elsif self.mailchimp_user.kind_of?(Hash)
      self.mailchimp_user["status"]
    end
  end

  # # syncs Mailchimp status to EBW, subscribing and unsubscribing users as appropriate. potential MC status includes
  # # 'subscribed', 'unsubscribed', 'pending' and 'cleaned'
  # def add_to_mailchimp
  #   gb = Gibbon::Request.new(api_key: ENV['MAILCHIMP_API_KEY'])
  #   if self.subscribed? # if the user has checked the "subscribed" checkbox
  #     if self.mailchimp_status.present? # if MailChimp recognizes the email address
  #       gb.lists(ENV['MAILCHIMP_LIST_ID']).members(Digest::MD5.hexdigest("#{self.email.downcase}")).update(body: { status: "subscribed" }) #subscribe user 
  #     elsif self.mailchimp_status.nil? # if MailChimp doesn't have a user for the email address
  #       gb.lists(ENV['MAILCHIMP_LIST_ID']).members.create(body: { # create a MailChimp pending subscriber
  #         email_address: "#{self.email}",
  #         status: "pending", # setting this to 'subscribed' will remove double optin
  #         merge_fields: {FNAME: "#{self.name}"}
  #         })
  #     end

  # # unsubscribe user if box is unchecked but mailchimp has user as subscribed or pending
  #   else
  #     unless self.mailchimp_user.kind_of?(Array)
  #       gb.lists(ENV['MAILCHIMP_LIST_ID']).members(self.mailchimp_member_id).update(body: { status: "unsubscribed" })  
  #     end
  #   end
  # end

end
