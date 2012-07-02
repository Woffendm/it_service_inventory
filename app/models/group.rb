class Group < ActiveRecord::Base
  attr_accessible :name, :employees
  validates_presence_of :name
  has_many :employees

  def get_available_employees
    available_employees = []
    Employee.all.each do |employee|
			if(employees.index(employee) == nil)
				available_employees.push(employee)
			end
		end
		return available_employees
  end

end
