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
    ldap = Net::LDAP.new :host => "client-ldap.onid.orst.edu", :port => 389
    treebase = "ou=People, o=orst.edu"
    ldap_results = ldap.search(:base => treebase, :filter => filter)
    return nil if ldap_results == false
    return ldap_results.sort_by { |u| u.cn }
  end
end



# The following line is going to be used later on when checking for updates to employee information.
# RemoteEmployee.update_search(Employee.first.osu_username, Employee.first.osu_id).first.uid.first