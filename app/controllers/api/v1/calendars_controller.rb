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

  private

    def calendar_params
      params.require(:calendar).permit(:calendar_name, :address, :phone)
    end

    def calendar_to_json(calendar)
      calendar.to_json(only: [:id, :calendar_name, :address, :phone, :public_uid])
    end
end