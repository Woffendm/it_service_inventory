class Group < ActiveRecord::Base
  attr_accessible :name, :employees
  has_and_belongs_to_many :employees
  validates_presence_of :name


  def get_available_employees
    available_employees = []
    Employee.order(:name).each do |employee|
			if(employees.index(employee) == nil)
				available_employees.push(employee)
			end
		end
		return available_employees
  end
end