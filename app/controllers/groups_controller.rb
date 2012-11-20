# This class controls the Group model, views, and related actions
#
# Author: Michael Woffendin 
# Copyright:

class GroupsController < ApplicationController
  before_filter :load_group,      :only => [:add_employee, :toggle_group_admin, :destroy, :edit,
                                            :remove_employee, :show, :update]  
  before_filter :authorize_update, :only => [:add_employee, :toggle_group_admin, :edit,
                                            :remove_employee, :update]
  before_filter :load_employee,   :only => [:add_employee]
  before_filter :load_possible_employees,  :only => [:edit]
  before_filter :load_existing_employees,  :only => [:show, :edit]
  before_filter :load_services,            :only => [:show]
  before_filter :load_products,            :only => [:show]
  
  
# View-related methods

  # Page for editing an existing group
  def edit
  end


  # List of all groups
  def index
    @group = Group.new
    @groups = Group.order(:name)
  end
  
  
  # Page for viewing an existing group
  def show
  end
  
# Action-related methods
  
  # Adds the employee selected on the "roster" page to the given group
  def add_employee
    @group.add_employee_to_group(@employee)
    flash[:notice] = t(:employee) + t(:added)
    redirect_to edit_group_path(@group.id)
  end
  
  
  # Gives / removes the selected employee administrative abilities for the group
  def toggle_group_admin
    employee_group = Employee.find(params[:employee]).employee_groups.find_by_group_id(params[:id])
    employee_group.update_attributes(:group_admin => !employee_group.group_admin)
    if employee_group.group_admin
      flash[:notice] = t(:admin) + t(:added)
    else
      flash[:notice] = t(:admin) + t(:removed)
    end
    redirect_to edit_group_path(@group.id)
  end
  
  
  # Creates a new group using the information entered on the "new" page
  def create
    authorize! :create, Group
    @group = Group.new(params[:group])
    if @group.save
      flash[:notice] = t(:group) + t(:created)
    else
      flash[:error] = t(:group) + t(:needs_a_name)
    end
    redirect_to groups_path
  end


  # Casts the selected group into an unfathomable abyss of destruction
  def destroy
    authorize! :destroy, Group
    @group.destroy 
    flash[:notice] = t(:group) + t(:deleted)
    redirect_to groups_path 
  end


  # Removes the employee selected on the "roster" page from the given group
  def remove_employee
    @employee = Employee.find(params[:employee])
    @group.remove_employee_from_group(@employee)
    flash[:notice] = t(:employee) + t(:removed)
    redirect_to edit_group_path(@group.id)
  end


  # Populates the service dropdown list on the "pages/home" page based on the group selected
  def services
    @selected_service = params[:selected_service]
    if params[:group][:id] == "0"
      @services = []
      Service.order(:name).each do |service|
        @services << service if service.employees.any?
      end
    else 
      @group = Group.find(params[:group][:id])
      @services = @group.services
    end
    render :layout => false
  end


  # Updates a group based on the information endered on the "edit" page
  def update
    if @group.update_attributes(params[:group])
      flash[:notice] = t(:group) + t(:updated)
      redirect_to edit_group_path(@group.id) 
      return
    end
    flash[:error] = t(:group) + t(:needs_a_name)
    render :edit
  end



# Loading methods

  private
    # Ensures user is authorized to update the group
    def authorize_update
      authorize! :update, @group
    end
    
    # Loads an employee based on given parameters
    def load_employee
      @employee = Employee.find(params[:employee][:id])
    end

    # Loads all employees
    def load_existing_employees
      @existing_employees = @group.employees.order(:name_last, :name_first).paginate(:page =>   
            params[:employees_page], :per_page => session[:results_per_page])
    end

    # Loads all employees not assigned to the group
    def load_possible_employees
      @possible_employees = @group.get_available_employees
    end

    # Loads a group based on given parameters
    def load_group
      @group = Group.find(params[:id])
    end
    
    # Loads all products allocated to the group
    def load_products
      @products = @group.products.order(:name).paginate(:page =>   
            params[:products_page], :per_page => session[:results_per_page])
    end
    
    # Loads all services allocated to employees of the group
    def load_services
      @services = @group.services.paginate(:page =>   
            params[:services_page], :per_page => session[:results_per_page])
    end
end
