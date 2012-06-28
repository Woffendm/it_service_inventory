class Employee < ActiveRecord::Base
  attr_accessible :name, :notes
  validates_presence_of :name
  belongs_to :group
  has_many :employee_allocations
  has_many :services, :through => :employee_allocations
  
  
  def get_available_services
    available_services = []
    Service.all.each do |service|
			if(services.index(service) == nil)
				available_services.push(service)
			end
		end
		return available_services
  end

end
