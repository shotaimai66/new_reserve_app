class Api::V1::UsersController < Api::Base
  skip_before_action :authenticate, only: [:create]

  def create
    @user = User.new(user_params)
    @calendar = @user.calendars.build(calendar_params)
    @task_course = @calendar.task_courses.build(task_course_params)
    
    if @user.save
      @staff = @calendar.staffs.create!(name: @user.name, email: @user.email, password: @user.password)
      user = user_and_relational_objects_to_json(@user)
      staff = @staff.to_json(only: [:id])
      render status: 200, json: { status: "200", message: "Created User and Relational Resourses", user: JSON.parse(user), staff: JSON.parse(staff) }
    else
      response_bad_request
    end
  end
  
  def update
    if params[:user][:password].blank?
      params[:user].delete('password')
      params[:user].delete('password_confirmation')
    end
    if @user.update(user_params)
      user = user_to_json(@user)
      render status: 200, json: { status: "200", message: "Updated User", user: JSON.parse(user) }
    else
      response_bad_request
    end
  end


  private

    def user_params
      params.require(:user).permit(:name, :email, :password)
    end

    def calendar_params
      params.require(:calendar).permit(:calendar_name, :address, :phone)
    end

    def task_course_params
      params.require(:task_course).permit(:title, :course_time, :charge, :description)
    end

    def user_and_relational_objects_to_json(user)
      user.to_json(
        only: [:id, :name, :email, :token],
        include: {
          calendars: { :only => [:id, :calendar_name, :address, :phone, :public_uid], 
            include: {
              task_courses: { :only => [:id, :title, :course_time, :charge, :desctiption] }
            }
          }
        }
      )  
    end

    def user_to_json(user)
      user.to_json(only: [:id, :name, :email])
    end
end