class Employee < ActiveRecord::Base
  attr_accessible :name, :notes, :groups
  has_and_belongs_to_many :groups
  has_many :employee_allocations
  has_many :services, :through => :employee_allocations
  validates_presence_of :name
  validates_format_of :name, :with => /[a-z]/

  
  def get_available_services
    available_services = []
    Service.order(:name).each do |service|
			if(services.index(service) == nil)
				available_services.push(service)
			end
		end
		return available_services
  end
end
