# This class is used to search the OSU LDAP directory for a given employee and return an array of
#    results
#
# Author: Michael Woffendin 
# Copyright:

class RemoteEmployee
  
  # This method searches the OSU LDAP directory for a given employee by first and last name and
  # returns an array of results
  def self.search(last_name, first_name)
    last_name_filter = Net::LDAP::Filter.eq("cn", last_name.to_s + "*")
    first_name_filter = Net::LDAP::Filter.eq("cn", "*,*" + first_name.to_s + "*")
    filter = last_name_filter & first_name_filter
    subroutine(filter)
  end
  
  
  # This method searches the OSU LDAP directory for a given employee by OSU id and ONID username and
  # returns an array with one result. 
  def self.find_by_username_and_id(osu_username, osu_id)
    id_filter = Net::LDAP::Filter.eq("osuuid", osu_id)
    username_filter = Net::LDAP::Filter.eq("uid", osu_username)
    filter = id_filter & username_filter
    subroutine(filter)
  end


  # This method preforms actions common to all above queries. They were consolodated into this one
  # method to avoid repetition.
  def self.subroutine(filter)
    ldap = Net::LDAP.new :host => Project1::Application.config.config['host'], 
                         :port => Project1::Application.config.config['port']
    ldap_results = ldap.search(:base => Project1::Application.config.config['treebase'], 
                         :filter => filter)
    return nil if ldap_results == false
    return ldap_results.sort_by { |u| u.cn }
  end
  
  
  # Updates the names and emails of all employees in the application using the latest information
  # retrieved from the ldap server specified
  def self.update_all_employees
    Employee.all.each do |employee|
      updated_info = self.find_by_username_and_id(employee.osu_username,
                     employee.osu_id).first
      updated_name = updated_info.cn.first.gsub(/[,]/, '').split(" ")
      employee.name_last = updated_name[0]
      employee.name_first = updated_name[1]
      employee.name_MI = updated_name[2]
      if updated_info.respond_to?(:mail)
        employee.email = updated_info.mail.first
      end
      employee.save
    end
  end
end