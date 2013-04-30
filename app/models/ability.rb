# This class stores information related to users' abilities. 
#
#
#
# Site Admin 
#     * Everything:   Create, update, destroy
#     * App settings: Update
#
# Group Admin 
#     * Employees:    Create, update those within group, delete those only belonging to group
#     * Groups:       Update own group
#     * Portfolios:   Create, update and destroy those belonging to group 
#     * Products:     Create, update, delete those without any allocations
#     * Services:     Create, update, delete those without any allocations
#
# Regular user
#     * Employee:     Update self if active
#
#
#
# Author: Michael Woffendin 
# Copyright:

class Ability
  include CanCan::Ability

  # Sets up the permissions outlined above
  def initialize(user)
    if user
      # Checks to see if user is site admin
      if user.site_admin
        can :manage, :all
      else
        admin_groups = Group.joins(:employee_groups).where(
                      :employee_id => user.id, :group_admin => true).includes(
                      :portolios, :products, :employees => :employee_groups)
        unless admin_groups.blank? 
          can :update, Group, :id => admin_groups.pluck(:id)
          can :create, Employee
          can :create, Portfolio
          can [:create, :update], Product
          can [:create, :update], Service
          admin_groups.each do |group|
            # Employees
            can :update, Employee, :id => group.employees.pluck(:id)
            group.employees.each do |employee|
              can :destroy, Employee, :id => employee.id if employee.employee_groups.length < 2
            end
            # Portfolios
            can [:update, :destroy], Portfolio, :id => group.portfolios.pluck(:id)
          end
          # Products
          can :destroy, Product, :id => Product.where("id not in (?)",
                                        Product.joins(:employee_products).pluck(:id)).pluck(:id)
          # Services
          can :destroy, Service, :id => Service.where("id not in (?)",
                                        Service.joins(:employee_allocations).pluck(:id)).pluck(:id)
        end
        # Regular users can only edit themselves if they are active.
        if user.active
          can :update, Employee, :id => user.id
        end
        # Anyone logged into the application can read everything.
        can :read, :all
      end
    end
  end
end
