require "spec_helper"

describe Group do
  
  # Validates presence of name prior to save
  it "should require a name" do
    group = Group.new
    group.should_not be_valid
    group.should have_at_least(1).error_on(:name)
  end
  
  
  describe "available employees" do
    employee = Employee.new
    employee.name = "some employee"
    employee.save
    group = Group.new
    
    
    # get_available_employees cannot return more employees than actually exist
    it "should be at most Employee.all" do
      assert (group.get_available_employees.length <= Employee.all.length)
    end
  
    
    group.employees.push(Employee.all)
    group.save
    
    
    # get_available_employees only returns available employees
    it "should return an empty array if there are no available employees" do
      assert group.get_available_employees == []
    end
  end
end