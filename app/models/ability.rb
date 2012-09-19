# This class stores information related to users' abilities. Here's the run down:
# => Site Admin: Can manage everything (Create groups, employees, set group administration, etc.).
#                Is the only one who can change application settings
# => Group Admin: Can manage services and the group that they admin. Can also update employees 
#                within their group and create new employees.
# => Everyone Else: Can view the employee index, group index, and group rosters. Can only edit their
#                own information (if they are in the database)
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
        user.employee_groups.each do |group|
          if group.group_admin
            can :update, Group, :id => group.group_id
            can [:create, :update], Service
            can [:create, :update], Product
            can :create, Employee
            # Group admins can edit info of all employees within their group
            Group.find(group.group_id).employees.each do |employee|
              can :update, Employee, :id => employee.id
            end
          end
        end
        # Everyone else can only edit themself and products they're assigned to
        user.products.each do |product|
          can :update, Product, :id => product.id
        end
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
