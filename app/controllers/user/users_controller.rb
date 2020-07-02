class User::UsersController < User::Base
  before_action :check_has_calendar
  before_action :update_token, only: [:new_api_key]

  def show
    @user = current_user
    @order_plans = @user.order_plans
  end

  def update
    @user = current_user
    if params[:user][:password].blank?
      params[:user].delete('password')
      params[:user].delete('password_confirmation')
    end
    if @user.update(user_params)
      sign_in(@user, bypass: true)
      flash[:success] = 'ユーザーの更新に成功しました。'
      redirect_to user_path(@user)
    else
      render action: :show
    end
  end

  # 現在のAPIキーを表示
  def api_key
    @user = current_user
  end

  # 新しいAPIキーを表示
  def new_api_key
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def check_has_calendar
    redirect_to google_auth_ident_form_url if current_user.calendars.first.nil?
  end

  # User.tokenを更新
  def update_token
    @user = current_user
    @user.token = User.generate_unique_secure_token
    @user.save!
  end
end
