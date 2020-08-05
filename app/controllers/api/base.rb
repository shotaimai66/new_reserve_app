# class Api::Base < ApplicationController
class Api::Base < ActionController::API 
  include ActionController::HttpAuthentication::Token::ControllerMethods
  include ApiResponse
  before_action :authenticate

  private

    def authenticate
      authenticate_or_request_with_http_token do |token, options|
        @user = User.find_by(token: token)
        @user != nil ? true : response_unauthorized
      end
    end
end