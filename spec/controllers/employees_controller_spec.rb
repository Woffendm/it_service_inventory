require 'spec_helper'

describe EmployeesController do

  context "handling GET index" do
    it "should render the index template" do
      get :index
      controller.should render_template("index")
    end
    
    it "should assign @employees => Employee.all" do
      get :index
      assigns[:employees].should == Employee.all
    end
  end
end
