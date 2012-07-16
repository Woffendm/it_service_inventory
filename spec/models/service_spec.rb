require "spec_helper"

describe Service do
  
  # Validates presence of name prior to save
  it "should require a name" do
    service = Service.new
    service.should_not be_valid
    service.should have_at_least(1).error_on(:name)
  end
end