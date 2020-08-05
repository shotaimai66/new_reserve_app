class User::PayjpController < User::Base
  before_action :authenticate_user!, except: %i[use privacy]
  before_action :has_order_plan?, only: [:form]
  before_action :correct_order_plan?, only: %i[destroy_order_operation destroy_order show]
  before_action :correct_user, only: %i[show destroy_order_operation destroy_order]
  before_action :set_smart_portal_url, only: %i[choice_plan complete_order show]
  skip_before_action :agreement_plan?
  skip_before_action :authenticate_user_staff!, only: %i[privacy use]
  skip_before_action :initial_setting_complete?, only: %i[privacy use]

  layout 'payjp'

  def choice_plan; end

  def form
    if Plan.find_by(plan_id: params[:plan_params])
      @plan = Plan.find_by(plan_id: params[:plan_params])
    else
      flash[:danger] = '決済パラメーターが不正です'
      redirect_to choice_plan_url
    end
  end

  def create_order
    customer = MyPayjp.create_customer(params['payjp-token'], current_user)
    plan = Plan.find_by(plan_id: params[:plan_id])
    if plan
      response = MyPayjp.create_subscription(customer, plan.plan_id, current_user)
      if response['error']
        flash[:danger] = '決済が完了しませんでした。入力内容を確認して、もう一度やり直してください。'
        redirect_to user_url(current_user)
      else
        order_plan = OrderPlan.create!(user_id: current_user.id, plan_id: plan.id, order_id: response['id'], card_number: customer['cards']['data'][0]['last4'])
        current_user.calendars.first.update(is_released: true)
        AgreementMailer.agreement_to_user(current_user, order_plan).deliver
        flash[:success] = '決済が完了しました。'
        redirect_to complete_order_url(order_plan)
        order_plan_webhook(order_plan)
      end
    else
      flash[:danger] = '決済パラメーターが不正です'
      redirect_to choice_plan_url
    end
  rescue Payjp::InvalidRequestError => e
    puts errors_log(e)
    flash[:danger] = '決済パラメーターが不正です'
    redirect_to choice_plan_url
  end

  def complete_order
    @order_plan = OrderPlan.find(params[:id])
    @plan = @order_plan.plan
  end

  def show
    @order_plan = OrderPlan.find(params[:id])
    @plan = @order_plan.plan
  end

  def destroy_order_operation
    @order_plan = OrderPlan.find_by(id: params[:id])
    @calendar_name = @order_plan.user.calendars.first.calendar_name
    if @order_plan && @order_plan.status == 'ongoing'
      @plan = @order_plan.plan
    else
      flash[:danger] = '登録されているプランではありません。'
      redirect_to user_url(current_user)
    end
  end

  def destroy_order
    @order_plan = OrderPlan.find(params[:id])
    response = MyPayjp.destroy_subscription(@order_plan)
    if response['error']
      puts response
      flash[:success] = '有料プランを解約できませんでした。'
    else
      @order_plan.update!(status: 1)
      current_user.calendars.first.update(is_released: false)
      AgreementMailer.cancellation_to_user(current_user, @order_plan).deliver
      flash[:success] = '有料プランを解約しました。'
      order_plan_webhook(@order_plan)
    end
    redirect_to user_url(current_user)
  end

  def privacy

  end

  def use
    
  end

  private

  def has_order_plan?
    if current_user.order_plans.any? { |order_plan| !order_plan.status_destroy? }
      flash[:danger] = 'すでにプランに登録済です。'
      redirect_to user_url(current_user)
    end
  end

  def correct_order_plan?
    @order_plan = OrderPlan.find(params[:id])
    @plan = @order_plan.plan
  end

  # ログイン中ユーザー以外のorder_planは表示しない
  def correct_user
    unless @order_plan.user_id == current_user.id
      flash[:danger] = '権限がありません。'
      redirect_to user_url(current_user)
    end     
  end

  # 課金状況が変更されたらポータルサイトに情報を送信
  def order_plan_webhook(order_plan)
    url = 
      Rails.env.development? ? ENV['DEVELOPMENT_SMART_PORTAL_URL'] + "/smart_yoyaku/webhook" : ENV['PRODUCTION_SMART_PORTAL_URL'] + "/smart_yoyaku/webhook"
    `curl -v POST "#{url}" \
    -d '{"app":"SmartYoyakuSystem","type":"UPDATED_ORDERPLAN_STATUS","order_plan":{"id":"#{order_plan.id}","status":"#{order_plan.status}"},"user":{"token":"#{current_user.token}"}}' \
    -H 'Content-Type:application/json'`
  end
end
