require "spec_helper"

describe Group do
  
  # Validates presence of name prior to save
  it "should require a name" do
    group = Group.new
    group.should_not be_valid
    group.should have_at_least(1).error_on(:name)
  end
  
  
  describe "available employees" do
    before do
      @employee = Employee.create(:name => "first employee")
      @employee_2 = Employee.create(:name => "last employee")
      @group = Group.create(:name => "some group")
      @group.employees.push(@employee)
    end
    
    
    # get_available_employees cannot return more employees than actually exist
    it "should be at most Employee.all" do
      @group.get_available_employees.length.should <= Employee.all.length
    end
  
    
    # get_available_employees returns only employees not currently assigned to the group
    it "should return only available employees" do
      @group.get_available_employees.first.id.should eq(@employee_2.id)
    end
  
    
    # get_available_employees only returns available employees
    it "should return an empty array if there are no available employees" do
      @group.employees.push(@employee_2)
      @group.get_available_employees.should be_empty
    end
  end
end