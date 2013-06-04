class ErrorsController < ApplicationController
  
  def internal_server_error
  end
  
  def invalid_credentials
    flash[:error] = params[:message]
    redirect '/'
  end
  
  def permission_denied
  end
  
  def page_not_found
  end
  
  def record_not_found
  end
  
end
