class User::DeliveryMessagesController < User::Base
  before_action :calendar

  def index
    @delivery_massages = DeliveryMessage.with_calendar(@calendar)
  end

  def show
    @delivery_massage = DeliveryMessage.with_calendar(@calendar).find_by(id: params[:id])
  end

  def new
    @delivery_massage = @calendar.delivery_messages.build
  end

  def create
    if params[:commit] == "下書き保存"
      @delivery_massage = @calendar.delivery_messages.build(params_delivery_calendar.merge(is_draft: true))
    else
      @delivery_massage = @calendar.delivery_messages.build(params_delivery_calendar)
    end
    if params[:delivery_type] == "now"
      @delivery_massage.attributes = {delivery_date: DateTime.current}
      if params[:delivery_scope] == "all"

      end
    end
    if @delivery_massage.save
      LinePush.new(@delivery_massage).push if params[:delivery_type] == "now"
      flash[:success] = "配信登録しました。"
      redirect_to calendar_delivery_messages_url(@calendar)
    else
      flash[:danger] = "登録できませんでした。"
      redirect_to calendar_delivery_messages_url(@calendar)
    end
  end

  def edit
    @delivery_message = DeliveryMessage.with_calendar(@calendar).find_by(id: params[:id])
  end

  def update
    @delivery_massage = DeliveryMessage.with_calendar(@calendar).find_by(id: params[:id])
    if params[:commit] == "下書き保存"
      @delivery_massage.attributes = params_delivery_calendar.merge(is_draft: true)
    else
      @delivery_massage.attributes = params_delivery_calendar
    end
    if params[:delivery_type] == "now"
      @delivery_massage.attributes = {delivery_date: DateTime.current}
      if params[:delivery_scope] == "all"
        
      end
    end
    if @delivery_massage.update(params_delivery_calendar)
      LinePush.new(@delivery_massage).push if params[:delivery_type] == "now"
      flash[:success] = "配信登録しました。"
      redirect_to calendar_delivery_messages_url(@calendar)
    else
      flash[:danger] = "登録できませんでした。"
      redirect_to calendar_delivery_messages_url(@calendar)
    end
  end

  def destroy
    @delivery_massage = DeliveryMessage.with_calendar(@calendar).find_by(id: params[:id])
    if @delivery_massage.destroy
      flash[:success] = "メッセージを削除しました。"
      redirect_to calendar_delivery_massages_url(@calendar)
    end
  end


  def params_delivery_calendar
    params.permit(:title, :message, :delivery_date)
  end

end
