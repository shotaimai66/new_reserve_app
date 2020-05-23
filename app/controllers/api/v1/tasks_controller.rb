class Api::V1::TasksController < Api::Base

  def index
    if params[:staff_id]
      # staff_idでタスクを特定
      tasks = Task.all.where(staff_id: params[:staff_id]).api_tasks
    else
      # userでカレンダーを特定→タスクを特定
      calendar = Calendar.find_by(user_id: @user.id)
      tasks = calendar.tasks.api_tasks
    end
    tasks = object_to_json(tasks)
    render json: { status: "200", message: "Loaded Tasks", tasks: JSON.parse(tasks) } 
  end

  def show
    task = Task.find(params[:id])
    task = object_to_json(task)
    render json: { status: "200", message: "Loaded Task", task: JSON.parse(task) }
  end

  private
   
  def object_to_json(object)
    object.to_json(
      methods: [:start_at, :end_at],
      only: [:id, :request, :started_at, :ended_at],
      include: {
        task_course: { :only => [:title, :description, :course_time, :charge] },
        store_member: { :only => [:name, :phone, :address] }
      }
    )
  end
end