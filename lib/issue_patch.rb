require_dependency 'issue'

# Patches Redmine's Issues dynamically. Adds a relationship
# Issue +belongs_to+ to Deliverable

module IssuePatch

  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
  end
  
  
  module ClassMethods
    
  end
  
  
  module InstanceMethods
    # Returns the issue's custom field value object for the designated custom field, if it has one.
    def get_custom_field_value(custom_field)
      self.custom_field_values.each do |cfv|
        next unless cfv.custom_field_id == custom_field.id
        return cfv
      end
      return nil
    end
    
    
    # Returns the value of the custom field for the issue. Use this one if you are displaying data
    # because you can include the custom_values in a query.
    def get_custom_value(custom_field)
      self.custom_values.each do |cv|
        next unless cv.custom_field_id == custom_field.id
        return cv.value
      end
      return nil
    end
  end

end

# Add module to Issue
Issue.send(:include, IssuePatch)