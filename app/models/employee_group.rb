class EmployeeGroup < ActiveRecord::Base
  attr_accessible :employee_id, :group_id, :group_admin, :employee, :group
  belongs_to :employee
  belongs_to :group
end
