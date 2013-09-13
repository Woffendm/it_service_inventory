# == Schema Information
#
# Table name: app_settings
#
#  id         :integer          not null, primary key
#  code       :string(255)
#  value      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class AppSettingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
