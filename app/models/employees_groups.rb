# This class links together employees and groups, enabling employees to have many groups and visa 
#   versa.
#
# Author: Michael Woffendin 
# Copyright:

class EmployeesGroups < ActiveRecord::Base
  attr_accessible :employee_id, :group_id
end
