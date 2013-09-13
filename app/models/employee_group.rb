# == Schema Information
#
# Table name: employee_groups
#
#  id          :integer          not null, primary key
#  employee_id :integer
#  group_id    :integer
#  group_admin :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  active      :boolean          default(TRUE)
#

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
  validates_uniqueness_of :employee_id, :scope => :group_id
  delegate :name, :to => :group
  
end
