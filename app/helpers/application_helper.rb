module ApplicationHelper
  
  def javascript(*files)
    content_for(:head) { javascript_include_tag(*files) }
  end

  def stylesheet(*files)
    content_for(:head) { stylesheet_link_tag(*files) }
  end
  
  
  # Returns a 'current' tag if given the current page
  def cp(path)
    "current_page" if current_page?(path)
  end
end
