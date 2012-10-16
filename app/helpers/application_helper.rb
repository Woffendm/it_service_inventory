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
  
  
  # Finds the longest word in the string (with a word being defined as something without spaces)
  # and returns a string with a max-width attribute assigned to be 10 times (in px) the length of 
  # the longest word if the longest word is longer than 20 characters
  def max_width_by_word(string)
    if split(" ").sort_by(&:length).last.length > 20
      return "max-width:#{string.split(" ").sort_by(&:length).last.length * 10}px;"
    end
    return ""
  end
  
  
  # If the string is longer than 20 characters, returns a string with a max-width attribute assigned 
  # to be 10 times (in px)the length of the string.
  def max_width_by_string(string)
    if string.length > 20
      return "max-width:#{string.length * 10}px;"
    end
    return ""
  end
end
