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
    data_array = []
    if @group && @service.nil?
      @employees = @group.employees.order(:name_last, :name_first)
      @graph_title = "Allocations for group: #{@group.name}"
      @x_axis_title = "Service"
      @employee_headcount = @group.employees.length
      @full_time_employees = @group.get_total_allocation
      @group.services.each do |service|
        data_array << service.total_allocation_within_group(@group)
      end
    end
    if @group.nil? && @service
      @employees = @service.employees.order(:name_last, :name_first)
      @graph_title = "Allocations for service: #{@service.name}"
      @x_axis_title = "Group"
      @employee_headcount = @service.employees.length
      @full_time_employees = @service.get_total_allocation
      @service.groups.each do |group|
        data_array << @service.total_allocation_for_group(group)
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
      data_array = @service.employee_allocations_within_group(@group)
      @employee_headcount = data_array.length
      @full_time_employees = @service.total_allocation_for_group(@group)[1]
    end
    @data_to_graph = ""
    data_array.each do |subarray|
      @data_to_graph += "["
      subarray.each do |subarray_entry|
        @data_to_graph += subarray_entry.to_s
        unless subarray_entry == subarray.last
          @data_to_graph += ","
        end
      end
      @data_to_graph += "]"
      unless subarray == data_array.last
        @data_to_graph += ","
      end
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