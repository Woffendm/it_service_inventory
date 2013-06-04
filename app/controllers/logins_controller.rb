# This class controls logins and session information. 
#
# Author: Michael Woffendin 
# Copyright:
class LoginsController < ApplicationController
  skip_before_filter :require_login
  skip_before_filter :remind_user_to_set_allocations



  # Redirects to secure onid login page
  def new
    redirect_to Project1::Application.config.config['ldap_login_path']
  end


  # Development tool for logging in without a password
  def new_backdoor
    redirect_to new_logins_path unless Rails.env.development?
  end


  # Changes the number of results that are displayed per page. Redirects to first page if referring
  # page was paginated. Redirects to previous page if page was not paginated. Redirects home if 
  # no referring page.  
  def change_results_per_page
    session[:results_per_page] = params[:results_per_page]
    referring_page = request.referer
    flash[:notice] = t(:results_per_page) + " #{params[:results_per_page]}"
    if referring_page
      if referring_page.index("page=")
        referring_page = referring_page[0..(referring_page.index("page=") + 4)] + "1"
      end
      redirect_to referring_page
    else
      redirect_to home_pages_path
    end
  end


  # Sets a cookie for the year being viewed / edited by the user. Expires in 15 minutes.
  def change_year
    cookies[:year] = { :value => params[:year], :expires => Time.now + 15.minutes }
    referring_page = request.referer
    flash[:notice] = "Year changed to " + " #{params[:year]}"
    if referring_page
      redirect_to referring_page
    else
      redirect_to home_pages_path
    end
  end


  # Sets session value to current user/employee (login)
  def create
    employee_exists = Employee.find_by_osu_username(params[:username].downcase)
    if employee_exists
      session[:current_user_name] = employee_exists.full_name
      session[:current_user_osu_username] = employee_exists.osu_username
      session[:results_per_page] = 25
      flash[:notice] = "Welcome " + employee_exists.name_first + "!"
      redirect_to home_pages_path
    else
      flash[:error] = "No employee with that ONID username is in the application"
      redirect_to new_logins_path
    end
  end


  # Development tool for logging in without a password
  def create_backdoor
    unless Rails.env.development?
      redirect_to new_logins_path
      return
    end
    employee_exists = Employee.find_by_osu_username(params[:username].downcase)
    if employee_exists
      session[:current_user_name] = employee_exists.full_name
      session[:current_user_osu_username] = employee_exists.osu_username
      session[:results_per_page] = 25
      flash[:notice] = "Welcome " + employee_exists.name_first + "!"
      redirect_to home_pages_path
    else
      flash[:error] = "No employee with that ONID username is in the application"
      redirect_to new_logins_path
    end
  end

  
  # Removes session value (logout)
  def logout
    session[:current_user_name] = nil
    session[:current_user_osu_username] = nil
    session[:results_per_page] = nil
    flash[:notice] = t(:logged_out)
    redirect_to new_logins_path
  end
end
