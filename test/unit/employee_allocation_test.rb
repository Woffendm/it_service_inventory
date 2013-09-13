# == Schema Information
#
# Table name: employee_allocations
#
#  id             :integer          not null, primary key
#  employee_id    :integer
#  service_id     :integer
#  allocation     :float
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  fiscal_year_id :integer
#

require 'test_helper'

class EmployeeAllocationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
