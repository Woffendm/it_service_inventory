# This class controls pages not directly related to any model
#
# Author: Michael Woffendin 
# Copyright: 

class PagesController < ApplicationController

  # Page used to rapidly search for an employee
  def home
    @services = Service.all
    @groups = []
    Group.order(:name).each do |group|
      if group.employees.any?
        @groups << group
      end
    end
  end

end