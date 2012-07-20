require "spec_helper"

describe Employee do
  
  # Validates presence of name prior to save
  it "should require a name" do
    employee = Employee.new
    employee.should_not be_valid
    employee.should have_at_least(1).error_on(:name_first)
    employee.should have_at_least(1).error_on(:name_last)
  end
  
  
  # Can save when given a name
  it "should save when given a name" do
    employee = Employee.new
    employee.name_first = "some"
    employee.name_last = "employee"
    employee.should be_valid
  end
  
  
  
  describe "only one of each employee" do
    before do
      @employee = Employee.new
      @employee.name_first = "some"
      @employee.name_last = "employee"
      @employee.osu_id = "1"
      @employee.osu_username = "bob"
      @employee.save
      @employee2 = Employee.new
      @employee2.name_first = "some"
      @employee2.name_last = "employee"
      @employee2.osu_id = "1"
      @employee2.osu_username = "bob"
    end
    
    
    it "should not save if there is already an employee with the same osu username and id" do
      @employee2.should_not be_valid
      @employee2.should have_at_least(1).error_on(:osu_id)
    end
    
    
    it "should save when given a unique osu username and id" do
      @employee2.osu_id = "unique id"
      @employee2.osu_username = "unique username"
      @employee2.should be_valid
    end
  end
  
  
  
  describe "available services" do
    before do
      @service = Service.create(:name => "first service")
      @service_2 = Service.create(:name => "last service")
      @employee = Employee.create(:name_first => "some", :name_last => "employee")
      @employee.employee_allocations.create(:service_id => @service.id, :allocation => 0.1)
    end

    
    # get_available_services cannot return more services than actually exist
    it "should be at most Service.all" do
      @employee.get_available_services.length.should <= Service.all.length
    end
    
    
    # get_available_services returns only services not currently assigned to the employee
    it "should return only available services" do
      @employee.get_available_services.first.id.should eq(@service_2.id)
    end

    
    # get_available_services returns an empty array if no services are available
    it "should return an empty array if there are no available services" do
      @employee.employee_allocations.create(:service_id => @service_2.id, :allocation => 0.1)
      @employee.get_available_services.should be_empty
    end
  end
end