class EmployeesController < ApplicationController
  
  before_filter :load_groups, :only => [:index, :new, :edit, :cheese]
  before_filter :load_employee, :only => [:update, :destroy, :edit, :add_service, :remove_service]
  before_filter :load_service, :only => [:add_service, :remove_service]
  #verify :params => "service", :only => [:add_service, :remove_service]
  
  
  
#View-related methods
  def home
    @employees = Employee.all
  end
  
  
  def index
    @employees = Employee.all
  end
  
  
  def new
    @employee=Employee.new
  end
  
  
  def create
    @employee=Employee.new(params[:employee])
    if @employee.save
      redirect_to employees_path
      return
    end
    render :new
  end
  
  
  def edit
    
  end
  
  
#Action-related methods
  def update
    if @employee.update_attributes(params[:employee])
      redirect_to employees_path 
      return
    end
      render :edit
  end
  
  
  def add_service
    @employee_allocation = @employee.employee_allocations.new(params[:employee_allocation])
    if @employee_allocation.save
      redirect_to edit_employee_path(@employee.id)
      return
    end
    render :edit
  end


  def remove_service
    @employee_allocation = @employee.employee_allocations.find(params[:employee_allocation])
    @employee_allocation.delete
    @employee.save
    redirect_to edit_employee_path(@employee.id)
  end
  
  
  def destroy
    @employee.destroy 
    redirect_to employees_path 
  end
  
  
  
#Loading methods
  private
    def load_groups
      @groups = Group.all
      @services = Service.all
    end
    
    
    def load_employee
      @employee=Employee.find(params[:id])
    end

    
    def load_service
      @index =  @employee.services.index(@service)
    end

end
