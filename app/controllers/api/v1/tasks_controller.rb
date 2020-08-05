class Api::V1::TasksController < Api::Base
  
  def index
    if params[:staff_id].nil?
      @tasks = @user.calendars.first.tasks.api_tasks
      tasks = task_to_json(@tasks)
      render status: 200, json: { status: "200", message: "Loaded Tasks", tasks: JSON.parse(tasks) }   
    elsif params[:staff_id].present?
      @staff = Staff.find_by(id: params[:staff_id])
      if @staff.nil?
        response_not_found(class_name = 'tasks')
      else
        if @user.calendars.ids.include?@staff.calendar_id
          @tasks = Task.all.where(staff_id: params[:staff_id]).api_tasks
          tasks = task_to_json(@tasks)
          render status: 200, json: { status: "200", message: "Loaded Tasks", tasks: JSON.parse(tasks) }
        else
          response_unauthorized
        end
      end   
    end
  end  

  def show
    @task = Task.find_by(id: params[:id])
    if @task.nil?
      response_not_found(class_name = 'task')  
    else
      if @task.calendar.user_id == @user.id
        task = task_to_json(@task)
        render status: 200, json: { status: "200", message: "Loaded Task", task: JSON.parse(task) }
      else
        response_unauthorized
      end
    end
  end


  private
    
    def task_to_json(task)
      task.to_json(
        methods: [:start_at, :end_at],
        only: [:id, :request, :start_at, :end_at],
        include: {
          task_course: { :only => [:title, :description, :course_time, :charge] },
          store_member: { :only => [:name, :email, :phone, :address] }
        }
      )
    end
end
