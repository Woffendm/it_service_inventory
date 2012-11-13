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
  # and returns a string with a max-width attribute assigned to be 0.6 times (in em) the length of 
  # the longest word if the longest word is longer than 42 characters
  def max_width_by_word(string)
    if !string.empty? && string.split(" ").sort_by(&:length).last.length > 42
      return "max-width:#{string.split(" ").sort_by(&:length).last.length * 0.6}em;"
    end
    return ""
  end
  
  
  # If the string is longer than 17 characters, returns a string with a max-width attribute assigned 
  # to be 0.6 times (in em) the length of the string.
  def max_width_by_string(string)
    if string.length > 17
      return "width:#{string.length * 0.6}em;"
    end
    return ""
  end
  
  
  def print_list_of_links(array)
    return array.collect{|g| link_to g.name, group_path(g.id)}.join(", ")
  end
end
