class User < ApplicationRecord
  include Encryptor
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :calendars
  has_many :orders
  has_many :system_plans, through: :orders
  has_many :order_plans
  has_many :plans, through: :order_plans
  accepts_nested_attributes_for :calendars

  serialize :google_api_token, Hash
  has_secure_token
end
