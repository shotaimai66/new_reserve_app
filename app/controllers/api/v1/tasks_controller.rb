class Api::V1::TasksController < Api::Base

  def index
    # 現状ではuserでカレンダーを特定→タスクを特定
    # 今後staff.idで絞り込むことになった場合には条件が変わる
    calendar = Calendar.find_by(user_id: @user.id)
    tasks = calendar.tasks.api_tasks.to_json(
      only: [:id, :request, :start_time, :end_time],
      include: {
        task_course: { :only => [:title, :description, :course_time, :charge] },
        store_member: { :only => [:name, :phone, :address] }
      }
    )
    render json: tasks
    # ↓↓↓こちらにするとjsonのレイアウトが変わる
    # render json: { status: "200", message: "Loaded Tasks", data: tasks } 
  end
end