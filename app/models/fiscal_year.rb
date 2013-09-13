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
  validate :at_least_one_active_fiscal_year
  after_save :change_active_fiscal_year



 # Returns all active fiscal years.
  def self.active_fiscal_years
    return FiscalYear.where(:active => true).order(:year)
  end
  
  
  
  protected
  
  # Ensures there is always at least one active fiscal year
  def at_least_one_active_fiscal_year
    return true if self.active
    if FiscalYear.active_fiscal_years.where("id != ?", self.id).length < 1
      self.errors.add(:active, "Must have at least one active fiscal year")
    end
  end
  
  
  
  # Changes the current fiscal yaer if the current year was set to inactive and was the current year
  def change_active_fiscal_year
    return true if self.active
    if AppSetting.current_fiscal_year == self
      AppSetting.find_by_code("current_fiscal_year").update_attributes(:value => FiscalYear.active_fiscal_years.first.year)
    end
  end
end
