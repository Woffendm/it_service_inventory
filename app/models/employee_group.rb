# This class links together Employees and Groups, enabling employees to have many groups and 
#   visa versa. It also store whether or not the given employee is an admin of the given group.
#
# Author: Michael Woffendin 
# Copyright:
class EmployeeGroup < ActiveRecord::Base
  attr_accessible :employee, :employee_id, :group, :group_admin, :group_id
  belongs_to :employee
  belongs_to :group
  validates_presence_of :employee_id, :group_id
end
