class Api::V1::StaffsController < Api::Base

  def update
    @staff = Staff.find_by(id: params[:id])
    if @staff.nil?
      response_bad_request
    else
      if @staff.calendar.user_id == @user.id
        if params[:staff][:password].blank?
          params[:staff].delete('password')
          params[:staff].delete('password_confirmation')
        end
        if @staff.update(staff_params)
          staff = staff_to_json(@staff)
          render status: 200, json: { status: "200", message: "Updated Staff", staff: JSON.parse(staff) }
        else
          response_bad_request
        end
      else
        response_unauthorized
      end
    end
  end

  private

    def staff_params
      params.require(:staff).permit(:name, :email, :password, :password_confirmation)
    end

    def staff_to_json(staff)
      staff.to_json(only: [:id, :name, :email])
    end
end