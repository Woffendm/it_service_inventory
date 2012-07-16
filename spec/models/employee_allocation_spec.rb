require "spec_helper"

describe EmployeeAllocation do
    describe "validate_total_allocation" do
      employee = Employee.new
      employee.name = "some employee"
      employee.save
      

      # Ensures that the employee has no errors and can save if its total allocation is less than 1
      it "should have no errors if total allocation is less than or equal to 1" do
        allocation_1 = employee.employee_allocations.new
        allocation_1.allocation = 1
        assert allocation_1.validate_total_allocation.nil?
        assert employee.errors.first.nil?
        assert employee.save 
      end


      # Ensures that the employee has errors and can not save if its total allocation exceeds 1
      it "should have errors if total allocation is greater than 1" do
        employee.employee_allocations.new.allocation = 1
        employee.save
        allocation_2 = employee.employee_allocations.new
        allocation_2.allocation = 0.1
        assert allocation_2.validate_total_allocation != nil
        assert employee.save == false     
      end
    end
  end