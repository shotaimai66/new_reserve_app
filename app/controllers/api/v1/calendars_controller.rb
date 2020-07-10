class Api::V1::CalendarsController < Api::Base

  def update
    @calendar = Calendar.find_by(public_uid: params[:calendar][:public_id])
    if @calendar.nil?
      response_bad_request      
    else
      if @calendar.user_id == @user.id
        @calendar.update(calendar_params)
        calendar = calendar_to_json(@calendar)
        render status: 200, json: { status: "200", message: "Updated Calendar", calendar: JSON.parse(calendar) }
      else
        response_unauthorized
      end
    end
  end

  # 予約カレンダーの表示を全て×または◯にする
  def update_holiday_flag
    @calendar = Calendar.find_by(public_uid: params[:calendar][:public_id])
    if @calendar.nil?
      response_bad_request      
    else
      if @calendar.user_id == @user.id
        @regular_holidays = @calendar.calendar_config.regular_holidays
        ActiveRecord::Base.transaction do
          if params[:calendar][:status] == "released"
            @regular_holidays.each { |holiday|
              holiday.holiday_flag = false
              holiday.save! }
          else
            @regular_holidays.each { |holiday|
              holiday.holiday_flag = true
              holiday.save! }
          end
        end
        calendar = calendar_to_json(@calendar)
        render status: 200, json: { status: "200", message: "Updated holiday flags", calendar: JSON.parse(calendar), calendar_status: "#{params[:calendar][:status]}" }
      else
        response_unauthorized
      end
    end
  end

  private

    def calendar_params
      params.require(:calendar).permit(:calendar_name, :address, :phone)
    end

    def calendar_to_json(calendar)
      calendar.to_json(only: [:id, :calendar_name, :address, :phone, :public_uid])
    end
end