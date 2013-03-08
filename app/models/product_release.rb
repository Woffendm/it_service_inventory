class ProductRelease < ActiveResource::Base

  PROJECT_ID = 387
  
  self.element_name = "deployment"
  self.site = 'https://2474efa3939725510d6696bfa65935d0e4dfb939:X@cws.oregonstate.edu/create/'
  self.proxy = "http://proxy.oregonstate.edu:3128"
  self.format = :xml

  # Define the attributes we want to access
  schema do
    attribute 'project_id', :integer
  end
  
end