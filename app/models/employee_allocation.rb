class EmployeeAllocation < ActiveRecord::Base
  attr_accessible :allocation, :employee_id, :service_id
  belongs_to :employee
  belongs_to :service
end
