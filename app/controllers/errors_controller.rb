class ErrorsController < ApplicationController
  
  def permission_denied
    @path = params[:path] 
  end
  
  def page_not_found
  end
  
  def record_not_found
  end
  
end
