class User::DeliveryMassagesController < User::Base

  def index
    @calendar = Calendar.find_by(calendar_uid: params[:calenar_id])
    @delevery_massages = DeliveryMassage.with_calendar(@calendar)
  end

  def show
    @calendar = Calendar.find_by(calendar_uid: params[:calenar_id])
    @delevery_massage = DeliveryMassage.with_calendar(calendar).find_by(id: params[:id])
  end

  def new
    @calendar = Calendar.find_by(calendar_uid: params[:calenar_id])
    @delivery_calenar = @calendar.delivery_messages.build
  end

  def create
    @calendar = Calendar.find_by(calendar_uid: params[:calenar_id])
    @delivery_calenar = @calendar.delivery_messages.build(params_delivery_calendar)
    if @delivery_calenar.save
      flash[:success] = "配信登録しました。"
      redirect_to calendar_delivery_massages_url(@calendar)
    else
      flash[:danger] = "登録できませんでした。"
      redirect_to calendar_delivery_massages_url(@calendar)
    end
  end

  def edit
    @calendar = Calendar.find_by(calendar_uid: params[:calenar_id])
    @delevery_massage = DeliveryMassage.with_calendar(calendar).find_by(id: params[:id])
  end

  def update
    @calendar = Calendar.find_by(calendar_uid: params[:calenar_id])
    @delevery_massage = DeliveryMassage.with_calendar(calendar).find_by(id: params[:id])
    if @delevery_massage.update(params_delivery_calendar)
      flash[:success] = "配信登録しました。"
      redirect_to calendar_delivery_massages_url(@calendar)
    else
      flash[:danger] = "登録できませんでした。"
      redirect_to calendar_delivery_massages_url(@calendar)
    end
  end

  def destroy
    @calendar = Calendar.find_by(calendar_uid: params[:calenar_id])
    @delevery_massage = DeliveryMassage.with_calendar(calendar).find_by(id: params[:id])
    if @delevery_massage.destroy
      flash[:success] = "メッセージを削除しました。"
      redirect_to calendar_delivery_massages_url(@calendar)
    end
  end


  def params_delivery_calendar
    params.require(:delivery_massage).permit(:title, :massage, :delivery_date, :is_draft)
  end

end
