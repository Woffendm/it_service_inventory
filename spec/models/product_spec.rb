# == Schema Information
#
# Table name: products
#
#  id                  :integer          not null, primary key
#  name                :string(255)
#  description         :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  url                 :string(255)
#  product_state_id    :integer
#  product_type_id     :integer
#  product_priority_id :integer
#

require 'spec_helper'

describe Product do
  pending "add some examples to (or delete) #{__FILE__}"
end
