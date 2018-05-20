# frozen_string_literal: true

class ApplicationController < ActionController::Base
  rescue_from ActionController::InvalidAuthenticityToken, with: :log_invalid_token_attempt

  if Rails.env.staging?
    http_basic_authenticate_with name: ENV['STAGING_USERNAME'], password: ENV['STAGING_PASSWORD']
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :state_objects

  helper_method :mailbox, :conversation

  before_action :store_user_location!, if: :storable_location?
  # The callback which stores the current location must be added before you authenticate the user 
  # as `authenticate_user!` (or whatever your resource is) will halt the filter chain and redirect 
  # before the location can be stored.
  before_action :authenticate_user!

  def info_for_paper_trail
    # Save additional info
    { ip: request.remote_ip }
  end

  def user_for_paper_trail
    # Save the user responsible for the action
    user_signed_in? ? current_user.id : 'Guest'
  end

  private

  def mailbox
    @mailbox ||= current_user.mailbox
  end

  def conversation
    @conversation ||= mailbox.conversations.find(params[:id])
  end

  def log_invalid_token_attempt
    warning_message = 'Invalid Auth Token error'
    Rails.logger.warn warning_message
    Rollbar.warning warning_message
    redirect_to '/'
  end

  # Its important that the location is NOT stored if:
  # - The request method is not GET (non idempotent)
  # - The request is handled by a Devise controller such as Devise::SessionsController as that could cause an 
  #    infinite redirect loop.
  # - The request is an Ajax request as this can lead to very unexpected behaviour.
  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr? 
  end

  def store_user_location!
    # :user is the scope we are authenticating
    store_location_for(:user, request.fullpath)
  end

  def state_objects
    @state_objects ||= State.all
  end


  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name
    devise_parameter_sanitizer.for(:account_update) << :name
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:name, :description, :subscribed, :email, :password, :password_confirmation) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:name, :description, :subscribed, :email, :password, :password_confirmation) }
  end
end
