# == Schema Information
#
# Table name: fiscal_years
#
#  id         :integer          not null, primary key
#  year       :integer
#  active     :boolean          default(TRUE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  seed_id    :integer
#

# Fiscal years are used to keep track of employee allocations over time. They may be used for other
#   purposes as well in the future.
#
# Author: Michael Woffendin 
# Copyright:

class FiscalYear < ActiveRecord::Base
  attr_accessible :year, :active
  has_many :employee_allocations
  has_many :employee_products
  validates_presence_of :year
  validates :year, :numericality => { :only_integer => true }
  validates_uniqueness_of :year


 # Returns all active fiscal years.
  def self.active_fiscal_years
    return FiscalYear.where(:active => true).order(:year)
  end
  
end
