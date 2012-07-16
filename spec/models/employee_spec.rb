require "spec_helper"

describe Employee do
  
  # Validates presence of name prior to save
  it "should require a name" do
    employee = Employee.new
    employee.should_not be_valid
    employee.should have_at_least(1).error_on(:name)
  end
  
  
  describe "available services" do
    service = Service.new
    service.name = "some service"
    service.save
    employee = Employee.new
    
    
    # get_available_services cannot return more services than actually exist
    it "should be at most Service.all" do
      assert (employee.get_available_services.length <= Service.all.length)
    end
  
    
    employee.services.push(service)
    employee.save
    
    
    # get_available_services only returns available services
    it "should return an empty array if there are no available services" do
      assert employee.get_available_services == []
    end
  end
end