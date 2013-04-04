# This class controls pages not directly related to any model
#
# Author: Michael Woffendin 
# Copyright: 

class PagesController < ApplicationController

  before_filter :load_groups_services
  before_filter :check_for_internet_explorer
  before_filter :load_all_years

  # Page used to rapidly search for information about groups, services, and employees. If user is
  # not logged in, will redirect them to login page. If user is logged in, will display information
  # related to their first group (provided they have one). 
  def home
    if @current_user.groups.first
      data_array = []
      @data_title_1 = t(:full_time_employees)
      @data_title_2 = t(:employee_headcount)
      @group = @current_user.groups.first
      @services = @group.services(@year)
      @employees = @group.employees.order(:name_last, :name_first)
      @graph_title = t(:allocations_for_group) + @group.name
      @x_axis_title = t(:service)
      @employee_headcount = @group.employees.length
      @full_time_employees = @group.get_total_service_allocation(@year, @allocation_precision)
      @group.services(@year).each do |service|
        data_array << service.total_allocation_within_group(@group, @year, @allocation_precision)
      end
      @data_to_graph = data_array.to_json
    end
  end


  # Retrieves and sets information related to the group and/or service selected by the user on the 
  # home page. Will not retrieve information if neither a group nor service is selected.
  def home_search
    @group = Group.find(params[:group][:id]) unless params[:group][:id].blank?
    @service = Service.find(params[:service][:id]) unless params[:service][:id].blank?
    data_array = []
    @data_title_1 = t(:full_time_employees)
    @data_title_2 = t(:employee_headcount)
    if @group && @service.nil?
      @services = @group.services(@year)
      @employees = @group.employees.order(:name_last, :name_first)
      @graph_title = t(:allocations_for_group) + @group.name
      @x_axis_title = t(:service)
      @employee_headcount = @group.employees.length
      @full_time_employees = @group.get_total_service_allocation(@year, @allocation_precision)
      @services.each do |service|
        data_array << service.total_allocation_within_group(@group, @year, @allocation_precision)
      end
    end
    if @group.nil? && @service
      @groups = @service.groups(@year)
      @employees = @service.employees.order(:name_last, :name_first)
      @graph_title = t(:allocations_for_service) + @service.name 
      @x_axis_title = t(:group)
      @employee_headcount = @service.employees.length
      @full_time_employees = @service.get_total_allocation(@year, @allocation_precision)
      @groups.each do |group|
        data_array << @service.total_allocation_for_group(group, @year, @allocation_precision)
      end
    end
    if @group && @service
      @services = @group.services(@year)
      @groups = @service.groups(@year)
      @employees = Employee.joins(:groups, :services).where(
                  :groups => {:id => 1}, :employee_allocations => {:fiscal_year_id => 1},
                  :services => {:id => 1}).order(:name_last, :name_first)
      @graph_title = t(:allocations_for_group) + @group.name + t(:and_service) + @service.name
      @x_axis_title = t(:employee)
      data_array = @service.employee_allocations_within_group(@group, @year, @allocation_precision)
      @employee_headcount = data_array.length
      @full_time_employees = @service.total_allocation_for_group(@group, @year,
            @allocation_precision)[1]
    end
    @data_to_graph = data_array.to_json if @group || @service
    render :home
  end



  private
    # Loads all services and groups which have employees
    def load_groups_services
      @services = []
      Service.order(:name).each do |service|
        @services << service if service.employees.any?
      end
      @groups = []
      Group.order(:name).each do |group|
        @groups << group if group.employees.any?
      end
    end
    
    
    # Loads all years. Loads the last selected year
    def load_all_years
      @year = @current_fiscal_year
    end
    
    
    # Checks to see if the user's browser is a version of Internet Explorer 8. If so, warns them
    # that IE8 does not display the graphs properly
    def check_for_internet_explorer
      result  = request.env['HTTP_USER_AGENT']
      if(result.index("MSIE") && result.index("8."))
        flash[:error] = t(:compatability_message)
      end
    end
end