class GroupsController < ApplicationController
  before_filter :load_employees, :only => [:index, :roster, :edit]
  before_filter :load_group, :only => [:edit, :update, :add_employee, :remove_employee, :destroy, :roster]
  before_filter :load_employee, :only => [:add_employee, :remove_employee]
  
  
  
#View-related methods
  def index
    @groups = Group.all
  end
  
  
  def new
    @group=Group.new
  end
  
  
  def create
    @group=Group.new(params[:group])
    if @group.save
      redirect_to groups_path
      return
    end
    render :new
  end
  
  
  def edit
  end
  
  
  def roster
  end
  
  
  
#Action-related methods
  def update
    @group.update_attributes(params[:group])
    redirect_to groups_path 
  end
  
  
  def add_employee
    @group.employees << @employee
    redirect_to roster_group_path(@group.id)
  end


  def remove_employee
    @group.employees.delete(@employee)
    redirect_to roster_group_path(@group.id)
  end
  
  
  def destroy
    @group.destroy 
    redirect_to groups_path 
  end
  
  
  
#Loading methods
  private
    def load_employees
      @employees = Employee.all
    end
  
  
    def load_group
      @group=Group.find(params[:id])
    end
    
    
    def load_employee
      @employee = Employee.find(params[:employee][:id])
    end
end
