# == Schema Information
#
# Table name: employees
#
#  id                 :integer          not null, primary key
#  first_name         :string(255)
#  last_name          :string(255)
#  middle_name        :string(255)
#  email              :string(255)
#  uid                :string(255)
#  osu_id             :string(255)
#  site_admin         :boolean
#  notes              :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  preferred_language :string(255)
#  preferred_theme    :string(255)
#  new_user_reminder  :boolean          default(TRUE)
#  active             :boolean          default(TRUE)
#  ldap_identifier    :string(255)
#

require "spec_helper"

describe Employee do

  # Validates presence of name prior to save
  it "should require a name" do
    employee = Employee.new
    employee.should_not be_valid
    employee.should have_at_least(1).error_on(:first_name)
    employee.should have_at_least(1).error_on(:last_name)
    employee.should have_at_least(1).error_on(:uid)
  end


  # Can save when given a name
  it "should save when given a name" do
    employee = Employee.new
    employee.first_name = "some"
    employee.last_name = "employee"
    employee.uid = "yoloswag4ever"
    employee.should be_valid
  end



  describe "only one of each employee" do
    before do
      @employee = Employee.new
      @employee.first_name = "some"
      @employee.last_name = "employee"
      @employee.osu_id = "1"
      @employee.uid = "bob"
      @employee.save
      @employee2 = Employee.new
      @employee2.first_name = "some"
      @employee2.last_name = "employee"
      @employee2.osu_id = "1"
      @employee2.uid = "bob"
    end


    # Ensures that there aren't any duplicate employees
    it "should not save if there is already an employee with the same osu username and id" do
      @employee2.should_not be_valid
    end


    # Unique employees are valid
    it "should save when given a unique osu username and id" do
      @employee2.osu_id = "unique id"
      @employee2.uid = "unique username"
      @employee2.should be_valid
    end
  end



  describe "available services" do
    before do
      @fiscal_year = FiscalYear.create(:year => 9001)
      @service = Service.create(:name => "first service")
      @service_2 = Service.create(:name => "last service")
      @employee = Employee.create(:first_name => "some", :last_name => "employee", :uid => "yoloswag4ever")
      @employee.employee_allocations.create(:service_id => @service.id, :allocation => 0.1, :fiscal_year_id => @fiscal_year.id)
    end


    # get_available_services cannot return more services than actually exist
    it "should be at most Service.all" do
      @employee.get_available_services(@fiscal_year).length.should <= Service.all.length
    end


    # get_available_services returns only services not currently assigned to the employee
    it "should return only available services" do
      @employee.get_available_services(@fiscal_year).first.id.should eq(@service_2.id)
    end


    # get_available_services returns an empty array if no services are available
    it "should return an empty array if there are no available services" do
      @employee.employee_allocations.create(:service_id => @service_2.id, :allocation => 0.1, :fiscal_year_id => @fiscal_year.id)
      @employee.get_available_services(@fiscal_year).should be_empty
    end
  end
end
