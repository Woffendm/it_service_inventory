class LoginsController < ApplicationController
 
  # Redirects to secure onid login page
  def new
    redirect_to '/auth/ldap'
  end
  
  
  # Development tool for logging in without a password
  def new_backdoor
    redirect_to employees_home_path unless Rails.env.development?
  end
  
  
  # Changes the number of results that are displayed per page. 
  def change_results_per_page
    session[:results_per_page] = params[:results_per_page]
    if request.referer
      flash[:notice] = t(:setting) + t(:updated)
      redirect_to request.referer
    else
      redirect_to employees_home_path
    end
  end
  
  
  # Sets session value to current user/employee (login)
  def create
    employee_exists = Employee.find_by_osu_username(params[:username].downcase)
    if employee_exists
      session[:current_user_id] = employee_exists.id
      session[:current_user_name] = employee_exists.full_name
      session[:results_per_page] = 25
      flash[:notice] = t(:logged_in_as) + session[:current_user_name]
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
      session[:results_per_page] = 25
      flash[:notice] = t(:logged_in_as) + session[:current_user_name]
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
    session[:results_per_page] = nil
    flash[:notice] = t(:logged_out)
    redirect_to employees_home_path
  end
end
