# This class stores information related to users' abilities. Here's the run down:
# => Site Admin: Can manage everything (Create groups, employees, set group administration, etc.).
#                Is the only one who can change application settings
# => Group Admin: Can create and update services. Can add and remove employees from the group that
#                 they admin, as well as change their group's name. Can update employees and
#                 products within their group and create new employees and products. Can delete 
#                 products, services, and employees that belong ONLY to their group (cannot delete
#                 an employee for example who belongs to this group AND another group), as well as
#                 unused employees, services, and products (Ones with no groups)
# => Everyone Else: Can view everything except application settings. Can only edit their
#                 own information.
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
        # Checks to see if user is an admin of any of their groups
        user.employee_groups.each do |employee_group|
          if employee_group.group_admin
            can :update, Group, :id => employee_group.group_id
            can :create, Product
            can :create, Employee
            can [:create, :update], Service
            # Can delete services assigned ONLY to their group
            employee_group.group.services.each do |service|
              if service.groups.length < 2
                can :destroy, Service, :id => service.id
              end
            end
            # Can edit info of all employees within their group
            employee_group.group.employees.each do |employee|
              can :update, Employee, :id => employee.id
              # Can delete employees assigned ONLY to their group
              if employee.groups.length < 2
                can :destroy, Employee, :id => employee.id
              end
            end
            # Can edit info of products assigned to their group
            employee_group.group.products.each do |product|
              can :update, Product, :id => product.id
              # Can delete products assigned ONLY to their group
              if product.groups.length < 2
                can :destroy, Product, :id => product.id
              end
            end
            # Can delete  and update products, services, and products not assigned to any groups 
            # (for cleanup purposes)
            Employee.all.each do |employee|
              if employee.groups.empty?
                can [:update, :destroy], Employee, :id => employee.id
              end
            end
            Service.all.each do |service|
              if service.groups.empty?
                can :destroy, Service, :id => service.id
              end
            end
            Product.all.each do |product|
              if product.groups.empty?
                can [:update, :destroy], Product, :id => product.id
              end
            end
          end
        end
        # Everyone else can only edit themself and products they're assigned to
        can :read, :all
        can :update, Employee, :id => user.id
      end
    end
    
    
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
