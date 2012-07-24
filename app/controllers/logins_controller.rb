class LoginsController < ApplicationController
 
  # Redirects to secure onid login page
  def new
    redirect_to '/auth/ldap'
  end
  
  
  # Development tool for logging in without a password
  def new_backdoor
    redirect_to employees_home_path unless Rails.env.development?
  end
  
  
  # Sets session value to current user/employee (login)
  def create
    employee_exists = Employee.find_by_osu_username(params[:username].downcase)
    if employee_exists
      session[:current_user_id] = employee_exists.id
      session[:current_user_name] = employee_exists.full_name
      flash[:notice] = "Logged in as: " + session[:current_user_name]
      redirect_to employees_home_path
    else
      flash[:error] = "No employee with that ONID username is in the application"
      render :new
    end
  end
  
  
  # Development tool for logging in without a password
  def create_backdoor
    redirect_to home_path unless Rails.env.development?
    employee_exists = Employee.find_by_osu_username(params[:username].downcase)
    if employee_exists
      session[:current_user_id] = employee_exists.id
      session[:current_user_name] = employee_exists.full_name
      flash[:notice] = "Logged in as: " + session[:current_user_name]
      redirect_to employees_home_path
    else
      flash[:error] = "No employee with that ONID username is in the application"
      render :new
    end
  end
  
  
  # Removes session value (logout)
  def destroy
    session[:current_user_id] = nil
    session[:current_user_name] = nil
    flash[:notice] = "Successfully logged out!"
    redirect_to employees_home_path
  end
end
