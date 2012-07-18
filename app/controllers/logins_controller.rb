class LoginsController < ApplicationController
  def new
    
  end
  
  
  # Sets session value to current user/employee
  def create
    employee_exists = Employee.find_by_osu_username(params[:username])
    if employee_exists
      session[:current_user_id] = employee_exists.id
      session[:current_user_name] = employee_exists.full_name
      flash[:notice] = "Logged in as: " + session[:current_user_name]
      redirect_to new_logins_path
    else
      flash[:error] = "No employee with that ONID username is in the application"
      render :new
    end
  end
  
  
  # Removes session value
  def destroy
    
  end
end
