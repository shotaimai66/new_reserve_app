class User::StoreMembersController < User::Base
  before_action :calendar

  def index
    @store_members = @calendar.store_members
  end

  def show

  end
end