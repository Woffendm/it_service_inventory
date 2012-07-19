require "spec_helper"

describe EmployeeAllocation do
    describe "validate_total_allocation" do
      before do
        @employee = Employee.create(:name_first => "some", :name_last => "employee")
        @allocation_1 = @employee.employee_allocations.new
        @allocation_1.allocation = 1
        @employee.save 
      end
      

      # Ensures that the employee has no errors and can save if its total allocation is less than 1
      it "should have no errors if total allocation is less than or equal to 1" do
        @allocation_1.should be_valid
      end


      # Ensures that the employee has errors and can not save if its total allocation exceeds 1
      it "should have errors if total allocation is greater than 1" do
        allocation_2 = @employee.employee_allocations.new
        allocation_2.allocation = 0.1
        allocation_2.should_not be_valid 
        @employee.should_not be_valid
      end
    end
  end