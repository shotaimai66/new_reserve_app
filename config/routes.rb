Rails.application.routes.draw do
  root :to => 'tops#top'
# ================================================================================================================-
  # api
  namespace 'api' do
    namespace 'v1' do
      resources :tasks, only: [:index, :show]
      resources :task_courses, only: [:index, :create, :update, :destroy]
      resources :staffs, only: [:update]
      resources :users, only: [:create]
      patch "/users", to: "users#update"
      patch "/calendars", to: "calendars#update"
      patch "calendars/update_holiday_flag", to: "calendars#update_holiday_flag" 
    end
  end
# ================================================================================================================-
  # googleカレンダー認証
  get 'google_auth/callback'
  get 'google_auth/redirect'
  get 'google_auth/ident_form'
  patch 'google_auth/identifier'
  patch 'google_auth/unlink'
# ================================================================================================================-
  # devise
  devise_for :admins, controllers: {
    sessions:      'admins/sessions',
    passwords:     'admins/passwords',
    registrations: 'admins/registrations'
  }
  scope :auth do
    devise_for :users, controllers: {
      sessions:      'users/sessions',
      passwords:     'users/passwords',
      registrations: 'users/registrations'
    }
  end
  devise_for :staffs, controllers: {
    sessions:      'staffs/sessions',
    passwords:     'staffs/passwords',
    registrations: 'staffs/registrations'
  }
  # rootページ用ルーティング
  # devise_scope :user do
  #   root :to => 'devise/sessions#new'
  # end
# ================================================================================================================-
  # admin権限
  scope module: :admin do
    get "admins/:id/dash_board", to: "dash_boards#top", as: :dash_board_top
    resources :plans
  end
# ================================================================================================================-
  # public権限
  scope module: :public do
    get "task_create", to: "tasks#task_create", as: :task_create
    get "processing", to: "tasks#processing", as: :processing
    get "task_create_without_line", to: "tasks#task_create_without_line", as: :task_create_without_line
    resources :calendars, only: [] do
      resources :tasks, except: [:show]
      get "tasks/:id/complete", to: "tasks#complete", as: :task_complete
      get "tasks/:id/cancel", to: "tasks#cancel", as: :task_cancel
      post "tasks/redirect_register_line", to: "tasks#redirect_register_line", as: :redirect_line
      get "tasks/:id/cancel_complete", to: "tasks#cancel_complete", as: :task_cancel_complete
    end
    # カレンダーが公開してない場合のページ
    get "not_released_page", to: "templetes#not_released_page"
  end
# ================================================================================================================-
  # user権限
  scope module: :user do
    resources :users do
      get "/api_key", to: "users#api_key" #スマートポータル連携用【現在のAPIキーを表示】
      get "/new_api_key", to: "users#new_api_key" #スマートポータル連携用【更新されたAPIキーを表示】
      patch "calendar/:id/update", to: "calendars#update"
      patch "calendar/:id/update_is_released", to: "calendars#update_is_released", as: "calendar_update_is_released"
      get "calendar/:id/calendar_preview", to: "calendars#calendar_preview", as: "calendar_preview"
      resources :calendars do
        get "dashboard", to: "top#dashboard"
        get "user_tasks/:id/update_by_drop", to: "user_tasks#update_by_drop"
        resources :user_tasks
        resources :task_courses
        resource :calendar_config
        get "staffs/staffs_shifts", to: "staffs#staffs_shifts", as: "staffs_shifts"
        resources :staffs
        resources :staff_rest_times
        get "staff_rest_times/:id/update_by_drop", to: "staff_rest_times#update_by_drop"
        resources :sub_tasks, only: [:create, :update, :edit]
        get 'sub_tasks/:id/update_by_drop', to: 'sub_tasks#update_by_drop'
        patch 'sub_tasks/:id/update_to_task', to: 'sub_tasks#update_to_task', as: "update_to_task"
      end
      get "calendar/:id/setting", to: "calendars#setting", as: "calendar_setting"
    end
    resources :calendars, only: [] do
      resources :store_members do
        resources :member_logs do
          collection {post :create_picture}
        end
        resources :member_pictures, only: [:create, :destroy]
      end
      get "store_member_task_show/:id", to:"store_members#store_member_task_show", as: "store_member_task_show"
      patch "store_member_task_update/:id", to: "store_members#update_task", as: "member_update_task"
      resources :iregular_holidays
      resources :staffs, only: [] do
        resources :staff_shifts
      end
    end
    resources :member_logs do
      resources :log_pictures, only: [:create, :destroy]
    end
    # =====userがアカウント登録した時の最初の設定ページ
    get "introductions/new_calendar", to: "introductions#new_calendar"
    post "introductions/create_calendar", to: "introductions#create_calendar"
    get "introductions/new_staff", to: "introductions#new_staff"
    post "introductions/create_staff", to: "introductions#create_staff"
    get "introductions/new_task_course", to: "introductions#new_task_course"
    post "introductions/craete_task_course", to: "introductions#craete_task_course"
    # =========

    # =====userの決済ロジック用(PAYjp)
    get 'pay/choice_plan', to: 'payjp#choice_plan', as: 'choice_plan'
    get 'pay/form', to: 'payjp#form', as: 'pay_form'
    post 'pay/create_order', to: 'payjp#create_order', as: 'pay_create_order'
    # post 'payments/registration_callback', to: 'payments#registration_callback', as: 'registration_callback'
    patch 'order_plan/:id/destroy_order', to: 'payjp#destroy_order', as: 'destroy_order'
    get 'order_plan/:id/complete_order', to: 'payjp#complete_order', as: 'complete_order'
    get 'order_plan/:id', to: 'payjp#show', as: 'order_plan'
    get 'order_plan/:id/destroy_order_operation', to: 'payjp#destroy_order_operation', as: "destroy_order_operation"
    get 'use', to: 'payjp#use', as: 'use'
    get 'privacy', to: 'payjp#privacy', as: 'privacy'
    # =========

    # =====userの決済ロジック用(GMO)
    get 'payments/form', to: 'payments#form', as: 'form'
    post 'payments/payment_callback', to: 'payments#payment_callback', as: 'payment_callback'
    post 'payments/registration_callback', to: 'payments#registration_callback', as: 'registration_callback'
    get 'payments/edit_credit', to: 'payments#edit_credit', as: 'edit_credit'
    # =========

  end
# ================================================================================================================-
  # staff権限

  scope module: :staff do
    get 'callback', to: 'line_links#callback', as: "line_link_staff"
    resources :calendars, only: [] do
      resources :staffs do
        resources :google_calendar_apis
        # スタッフのライン連携
        post 'line_links/redirect_line', to: 'line_links#redirect_line', as: "redirect_line"
      end
      get 'staffs/:id/google', to: 'staffs#google', as: 'google'
    end
  end

# ================================================================================================================-
  # 決済関連
  get 'law', to: 'laws#law', as: 'law'

# ================================================================================================================-
  # lambda_function関係
  scope module: :lambda_function do
    scope module: :api do
      post 'lambda_function/api/tasks/reminder', to: "tasks#reminder"
      post 'lambda_function/api/tasks/test', to: "tasks#test"
      post 'lambda_function/api/tasks/test_raise', to: "tasks#test_raise"

      post 'lambda_function/api/staff_shifts/create', to: "staff_shifts#create"
      post 'lambda_function/api/staff_shifts/test', to: "staff_shifts#test"
    end
  end
# ================================================================================================================-
  # LINE richメニュー
  post "line/webhook", to:"api/line/rich#webhook"

# ================================================================================================================-

  # help
  scope module: :user do
    get "user/helps", to:"helps#user_modal"
  end

  # mount ActionCable.server => '/cable'

end
