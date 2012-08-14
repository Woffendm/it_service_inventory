# This class controls pages not directly related to any model
#
# Author: Michael Woffendin 
# Copyright: 

class PagesController < ApplicationController

  before_filter :load_groups_services

  # Page used to rapidly search for an employee
  def home
    @data_to_graph = "none"
  end


  #
  def home_search
    unless params[:group][:id].blank?
      @group = Group.find(params[:group][:id])
    end
    unless params[:service][:id].blank?
      @service = Service.find(params[:service][:id])
    end
    @data_to_graph = ""
    if @group && @service.nil?
      @employees = @group.employees.order(:name_last, :name_first)
      @graph_title = "Allocations for group: #{@group.name}"
      @x_axis_title = "Service"
      @group.services.each do |service|
        @data_to_graph += service.total_allocation_within_group(@group)
        unless service == @group.services.last
          @data_to_graph += ","
        end
      end
    end
    if @group.nil? && @service
      @employees = @service.employees.order(:name_last, :name_first)
      @graph_title = "Allocations for service: #{@service.name}"
      @x_axis_title = "Group"
      @service.groups.each do |group|
        @data_to_graph += @service.total_allocation_for_group(group)
        unless group == @service.groups.last
          @data_to_graph += ","
        end
      end
    end
    if @group && @service
      @employees = []
      @service.employees.order(:name_last, :name_first).each do |employee|
        employee.groups.each do |group|
          if group == @group
            @employees << employee
          end
          break;
        end
      end
      @graph_title = "Allocations for group: #{@group.name}, and service: #{@service.name}"
      @x_axis_title = "Employee"
      @data_to_graph = @service.employee_allocations_within_group(@group)
    end
    @data_to_graph = "[" + @data_to_graph + "]"
    render pages_home_path  
  end


  private
    # Loads all services and groups which have employees
    def load_groups_services
      @services = []
      Service.order(:name).each do |service|
        if service.employees.any?
          @services << service
        end
      end
      @groups = []
      Group.order(:name).each do |group|
        if group.employees.any?
          @groups << group
        end
      end
    end
end