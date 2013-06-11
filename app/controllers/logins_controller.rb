# This class controls logins and session information. 
#
# Author: Michael Woffendin 
# Copyright:
class LoginsController < ApplicationController
  skip_before_filter :get_current_user, :only => [:new_backdoor, :create_backdoor]
  skip_before_filter :remind_user_to_set_allocations



  # Development tool for logging in as any user without a password
  def new_backdoor
    redirect_to logout_path unless Rails.env.development?
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


  # Sets session value to current user/employee (currently unused)
  def create
    employee_exists = Employee.find_by_uid(params[:username].downcase)
    if employee_exists
      session[:results_per_page] = 25
      flash[:notice] = "Welcome " + employee_exists.first_name + "!"
      redirect_to home_pages_path
    else
      flash[:error] = "No employee with that ONID username is in the application"
      redirect_to logout_path
    end
  end


  # Development tool for logging in without a password
  def create_backdoor
    unless Rails.env.development?
      redirect_to logout_path
      return
    end
    uid = params[:username].downcase
    if Employee.find_by_uid(uid) || Employee.ldap_create(uid)
      session[:cas_user] = uid
      redirect_to home_pages_path
      return
    else
      redirect_to new_logins_backdoor_path
    end
  end

  
  # Removes session value (currently used)
  def destroy
    session[:results_per_page] = nil
    flash[:notice] = t(:logged_out)
    redirect_to logout_path
  end
end
