class AddActiveFieldToEmployeesAndEmployeeGroups < ActiveRecord::Migration
  def up
    add_column :employee_groups, :active, :boolean
    add_column :employees, :active, :boolean
    
    Employee.all.each do |employee|
      employee.active = true
      employee.save
    end
    EmployeeGroup.all.each do |employee_group|
      employee_group.active = true
      employee_group.save
    end
  end
  
  def down
    remove_column :employee_groups, :active
    remove_column :employees, :active
  end
end
