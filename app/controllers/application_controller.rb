class ApplicationController < ActionController::Base
  # protect_from_forgery
  protect_from_forgery with: :exception
  alias devise_current_user current_user
  before_action :store_current_location, unless: :devise_controller?

  # 他のエラーハンドリングでキャッチできなかった場合に
  # 500 Internal Server Error(システムエラー)を発生させる
  # NOTE: rescue_from は下から評価されるので記載箇所はここが正解
  rescue_from Exception, with: :handle_500 unless Rails.env.development?

  # 例外に合わせたエラーハンドリング
  # 404 Not Found リソースが見つからない。アクセス権がない場合にも使用される
  rescue_from ActionController::RoutingError, with: :handle_404 unless Rails.env.development?
  rescue_from ActiveRecord::RecordNotFound,   with: :handle_404 unless Rails.env.development?
  # rescue_from ActiveRecord::RecordNotUnique, with: :render_409
  # rescue_from UnauthorizedError,             with: :render_401
  # rescue_from IllegalAccessError,            with: :render_403

  # エラーハンドリング処理
  def handle_500(exception = nil)
    logger.info "Rendering 500 with exception: #{exception.message}" if exception
    Slack500.post(request,exception) unless Rails.env.development?

    if request.xhr?
      # Ajaxのための処理
      render json: { error: '500 error' }, status: 500
    else
      render template: 'errors/error_500', status: 500, layout: 'application', content_type: 'text/html'
    end
  end

  def handle_404(exception = nil)
    logger.info "Rendering 404 with exception: #{exception.message}" if exception
    Slack500.post(request,exception) unless Rails.env.development?
    if request.xhr?
      # Ajaxのための処理
      render json: { error: '404 error' }, status: 404
    else
      render template: 'errors/error_404', status: 404, layout: 'application', content_type: 'text/html'
    end
  end

  def current_user
    if current_staff
      current_staff.calendar.user
    else
      begin
        User.find_by_id(devise_current_user.id)
      rescue StandardError
        nil
      end
    end
  end

  def after_sign_in_path_for(resource)
    if current_admin
      dash_board_top_path(resource)
    elsif current_staff
      user_calendar_dashboard_path(current_user, current_user.calendars.first)
    elsif current_user.calendars.empty?
      introductions_new_calendar_path
    else
      stored_location_for(:user) || user_calendar_dashboard_path(current_user, current_user.calendars.first) # ログイン後に遷移するpathを設定
    end
  end

  def after_sign_out_path_for(_resource)
    case _resource
    when :user
      new_user_session_url
    else
      new_staff_session_url # ログアウト後に遷移するpathを設定
    end
  end

  # ログアウト状態でアクセスしたURLを記憶
  def store_current_location
    return if current_user
    store_location_for(:user, request.url)
  end

  def end_time(start_time, task_course)
    t = Time.parse(start_time)
    t.since(task_course.course_time.minutes)
  end

  def check_calendar_info
    calendar = Calendar.find_by(public_uid: params[:id])
    redirect_to google_auth_redirect_path if calendar.calendar_id.blank?
  end

  def errors_log(e)
    text = <<-EOS
      ===========errors start==============
      =====================================
      #{e}
      =====================================
      ==============end====================
    EOS
    puts text
  end
end
