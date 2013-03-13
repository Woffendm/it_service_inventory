class Cody < ActiveResource::Base
  
  self.site = 'http://10-196-29-235.wireless.oregonstate.edu:3001/'
  self.format = :json
  self.user = 'cody'
  self.password = 'nivens'
  
end