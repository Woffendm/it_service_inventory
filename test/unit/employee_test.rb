# == Schema Information
#
# Table name: employees
#
#  id                 :integer          not null, primary key
#  first_name         :string(255)
#  last_name          :string(255)
#  middle_name        :string(255)
#  email              :string(255)
#  uid                :string(255)
#  osu_id             :string(255)
#  site_admin         :boolean
#  notes              :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  preferred_language :string(255)
#  preferred_theme    :string(255)
#  new_user_reminder  :boolean          default(TRUE)
#  active             :boolean          default(TRUE)
#  ldap_identifier    :string(255)
#

require 'test_helper'

class EmployeeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
