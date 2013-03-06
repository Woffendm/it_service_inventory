module ApplicationHelper
  
  def javascript(*files)
    content_for(:head) { javascript_include_tag(*files) }
  end

  def stylesheet(*files)
    content_for(:head) { stylesheet_link_tag(*files) }
  end
  
  
  # Returns a 'current' tag if given the current page
  def cp(path)
    "current_page" if request.fullpath.index(path)
  end
  
  
  # Returns an 'active' tag if given current page
  def ct(path)
    "active" if request.fullpath == path
  end
  
  
  # Returns an 'active' tag if the two arguments are equal
  def active_if_equal(arg1, arg2)
    "active" if arg1 == arg2
  end
  
  
  # Returns a link to the desired controller with paramaters for the table name, field to sort on, 
  # the current field being sorted on, and whether the list is ascending. Appends a ? or & to the 
  # given path depending on whether or not there were already paramaters, thus allowing filtering
  # and sorting to stack. To prevent the url from growing too large, prexisting sorting information 
  # is removed from the provided path.
  def sort_column(title, path, table, field, order, ascending)
    path = path[0..(path.index("table=")-2)] if path.index("table=")
    if path.index("?").nil?
      path = path + "?"
    else
      path = path + "&"
    end
    return link_to title, path + 
            "table=#{table}&order=#{field}&current_order=#{order}&ascending=#{ascending}"
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
