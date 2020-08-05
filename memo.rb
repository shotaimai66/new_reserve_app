予約の時間表示ヘルパー
reservation_date(task)

rails g migration AddMemoToTask memo:text
rails g migration AddMemoToStoreMember memo:text

rails g migration AddDviseToStaff

reala155@hotmail.com

rails g migration AddIsAllowNoticeToStoreMember boolean:is_allow_notice

rails g migration AddGoogleToStaff client_id:text client_secret:text google_api_token:text

rails g controller Rows
rails g migration AddBookingMessageToCalendarConfig booking_message:text

rails g migration AddMemberIdToUser member_id:strig

rails g model SystemPlan title:string plan_id:string charge:integer description:text

rails g model Order order_id:string

User.first.update(member_id: "333333")
Calendar.first.update(is_released: false)

http://localhost:3000/payments/form

rails g migration AddGoogleCalendarToStaff client_secret:string client_id:string google_api_token:string
rails g controller Staff::GoogleCalendarApis

システムプラン作成
SystemPlan.create!(title: "有料プラン", plan_id: "P001", charge: 5000, description: "有料プランです。")

User.all.each {|user| Order.create(user_id: user.id, system_plan_id:1, order_id: "#{user.id}0000")}
rails staff_shifts:create
User.all.each {|user| user.update(member_id: "#{user.id}1111")}

rails g migration AddRefreshTokenToStaff refresh_token:string

https://www.yoyaku-app.com/google_auth/callback



rails g migration AddBookingLinkToCalendarConfig booking_link:string
rails g migration AddSpecialModalFlagToCalendarConfig special_modal_flag:boolean

rails g migration AddDisplayIntervalTimeToCalendar display_interval_time:integer

update(special_modal_flag: true)

mysql -h clone-minpro-rds.clrfy79vwafb.ap-northeast-1.rds.amazonaws.com -P 3306 -u minpuro -p
sg-0eff63d64ab8ad7cd
ssh -i /Users/shota6/.ssh/clone.pem ec2-user@ec2-52-68-136-43.ap-northeast-1.compute.amazonaws.com

rails g model Plan title:string charge:integer description:text plan_id:string

rails g model OrderPlan order_id:string 

rails g migration AddCardNumberToOrderPlan card_number:string

rails g migration AddStatusToOrderPlan status:integer

Plan.create!(title: "基本プラン", plan_id: "pln_999b5d0dda45465e852493c80719", charge: 5000, description: "有料プランです。")
User.all.each {|user| OrderPlan.create(user_id: user.id, plan_id:2, order_id: "free_plan") if !user.order_plans.any? }

blue: ssh -i /Users/shota6/.ssh/smart-yoyaku-ohaio.pem ec2-user@ec2-3-136-161-102.us-east-2.compute.amazonaws.com

green: ssh -i /Users/shota6/.ssh/smart-yoyaku-ohaio.pem ec2-user@ec2-52-69-36-7.ap-northeast-1.compute.amazonaws.com

bundle exec whenever --update-crontab

sudo chmod 666 /var/app/current/log/cron.log /var/app/current/log/production.log

curl -X POST http://localhost:3000/lambda_function/task/tasks/reminder

http://localhost:3000/lambda_function/imai/shotas/reminder

curl -X POST https://www.yoyaku-app.com/lambda_function/api/tasks/reminder

http://localhost:3000/calendars/414e98b1/tasks/new?course_id=1&staff_id=1&start_time=2019-12-30T9%3A0%3A00%2B09%3A00

http://localhost:3000/pay/choice_plan


"文字列を入力してください！"
line = gets

result = line.split("").map do |a|
  sample[:a]
end

puts result

if browser.device.mobile?
end


###############
production: ssh -i ~/.ssh/smart_yoyaku.pem ec2-user@3.113.2.41

staging: ssh -i ~/.ssh/smart_yoyaku.pem ec2-user@52.195.9.72