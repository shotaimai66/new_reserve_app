class ApplicationController < ActionController::Base

  def after_sign_in_path_for(resource)
    if current_admin
      dash_board_top_path(resource)
    elsif current_user.calendars.size == 0
      introductions_new_calendar_path
    else
      user_calendar_dashboard_path(current_user, current_user.calendars.first) # ログイン後に遷移するpathを設定
    end
  end

  def after_sign_out_path_for(resource)
    new_user_session_path # ログアウト後に遷移するpathを設定
  end

  def end_time(start_time, task_course)
    t = Time.parse(start_time)
    t.since(task_course.course_time.minutes)
  end


  private
  def check_calendar_info
    calendar = Calendar.find_by(calendar_name: params[:calendar_calendar_name])
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
  end
end
