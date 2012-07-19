class LoginsController < ApplicationController
  def new
    
  end
  
  
  # Sets session value to current user/employee (login)
  def create
    employee_exists = Employee.find_by_osu_username(params[:username].downcase)
    if employee_exists
      session[:current_user_id] = employee_exists.id
      session[:current_user_name] = employee_exists.full_name
      flash[:notice] = "Logged in as: " + session[:current_user_name]
      redirect_to new_logins_path
    else
      session[:current_user_id] = nil
      session[:current_user_name] = "Guest"
      flash[:error] = "No employee with that ONID username is in the application. Logged in as Guest"
      render :new
    end
  end
  
  
  # Removes session value (logout)
  def destroy
    session[:current_user_id] = nil
    session[:current_user_name] = "Guest"
    flash[:notice] = "Successfully logged out!"
    redirect_to new_logins_path
  end
end
