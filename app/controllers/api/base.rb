# class Api::Base < ApplicationController
class Api::Base < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate

  protected

  def authenticate
    authenticate_or_request_with_http_token do |token, options|
      @user = User.find_by(token: token)
      @user != nil ? true : render_unauthorized_request
    end
  end
end