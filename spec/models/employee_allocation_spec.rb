require "spec_helper"

describe EmployeeAllocation do
    describe "validate_total_allocation" do
      before do
        @employee = Employee.create(:name_first => "some", :name_last => "employee")
        @allocation_1 = @employee.employee_allocations.new
        @employee.save 
      end


      # Ensures that employee allocation cannot save if it has blank fields
      it "should not be valid if it has blank fields" do
        # service_id, allocation, and fiscal_year_id are blank
        @allocation_1.should_not be_valid
        @allocation_1.service_id = 1
        # allocation and fiscal_year_id are still blank
        @allocation_1.should_not be_valid
        @allocation_1.allocation = 0.1
        # fiscal_year_id is still blank
        @allocation_1.should_not be_valid
      end


      # Ensures that employee allocation is valid if all its fields have entries
      it "should be valid if all fields have entries" do
        @allocation_1.employee_id = 1
        @allocation_1.service_id = 1
        @allocation_1.allocation = 0.1
        @allocation_1.fiscal_year_id = 1
        @allocation_1.should be_valid
      end
    end
  end