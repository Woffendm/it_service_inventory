class Employee < ActiveRecord::Base
  attr_accessible :name, :notes
  validates_presence_of :name
  #Begin useless validation testing
  validates :name, :length => { :minimum => 2}
  validate :validate_notes
  #End useless validation testing
  belongs_to :group
  has_many :employee_allocations
  has_many :services, :through => :employee_allocations

  def validate_notes
    if notes.length > 20
      errors.add(:notes, "You take too many notes!")
    end
  end
  

  
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
