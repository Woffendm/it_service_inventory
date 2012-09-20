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
    redirect_to pages_home_path unless Rails.env.development?
  end


  # Changes the number of results that are displayed per page. Redirects to first page if referring
  # page was paginated. Redirects to previous page if page was not paginated. Redirects home if 
  # no referring page.  
  def change_results_per_page
    session[:results_per_page] = params[:results_per_page]
    referring_page = request.referer
    if referring_page
      flash[:notice] = t(:results_per_page) + " #{params[:results_per_page]}"
      if referring_page.index("=")
        referring_page = referring_page[0..referring_page.index("=")] + "1"
      end
      if !params[:name_to_search_for].blank?
        referring_page += "&name_to_search_for=#{params[:name_to_search_for]}"
      end
      redirect_to referring_page
    else
      redirect_to pages_home_path
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
      redirect_to pages_home_path
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
      session[:current_user_name] = employee_exists.full_name
      session[:current_user_osu_username] = employee_exists.osu_username
      session[:results_per_page] = 25
      flash[:notice] = "Welcome " + employee_exists.name_first + "!"
      redirect_to pages_home_path
    else
      flash[:error] = "No employee with that ONID username is in the application"
      render :new
    end
  end

  
  # Removes session value (logout)
  def destroy
    session[:current_user_name] = nil
    session[:current_user_osu_username] = nil
    session[:results_per_page] = nil
    flash[:notice] = t(:logged_out)
    redirect_to logins_new_path
  end
end
