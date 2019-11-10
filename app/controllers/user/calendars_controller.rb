class User::CalendarsController < User::Base
  before_action :calendar, except: %i[new create]

  def new
    @calendar = current_user.calendars.build
  end

  def create
    @calendar = current_user.calendars.build(params_calendar)
    if @calenar.save
    end
  end

  def show
    @user = current_user
  end

  def update
    @user = current_user
    if @calendar.update(params_calendar)
      # スタッフのシフトを作成（base.rbに記載）
      if @calendar.saved_change_to_display_week_term?
        create_calendar_staffs_tasks(@calendar)
      end
      flash[:succese] = 'カレンダーの設定を更新しました。'
      redirect_to user_calendar_url(@user, @calendar)
    else
      @calendar.reload
      render action: :show
    end
  end

  def update_is_released
    @calendar = Calendar.find_by(public_uid: params[:id])
    if params[:commit] == '公開にする'
      if @calendar.update(is_released: true)
        flash[:succese] = 'カレンダーを公開しました'
        redirect_to user_calendar_dashboard_url(current_user, @calendar)
      end
    else
      if @calendar.update(is_released: false)
        flash[:succese] = 'カレンダーを非公開にしました'
        redirect_to user_calendar_dashboard_url(current_user, @calendar)
      end
    end
  rescue StandardError
    flash[:danger] = '更新できませんでした'
    redirect_to user_calendar_dashboard_url(current_user, @calendar)
  end

  private

  def params_calendar
    params.require(:calendar).permit(:start_date, :end_date, :display_week_term, :public_uid, :is_released, :address, :phone, :start_time, :end_time, :display_time, :display_interval_time)
  end
end
