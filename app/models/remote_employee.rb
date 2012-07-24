# This class is used to search the OSU LDAP directory for a given employee and return an array of
#    results
#
# Author: Michael Woffendin 
# Copyright:

class RemoteEmployee
  
  # This method searches the OSU LDAP directory for a given employee by first and last name and
  # returns an array of results
  def self.search(last_name, first_name)
    ldap = Net::LDAP.new :host => "client-ldap.onid.orst.edu", :port => 389
    filter1 = Net::LDAP::Filter.eq("cn", last_name.to_s + "*")
    filter2 = Net::LDAP::Filter.eq("cn", "*,*" + first_name.to_s + "*")
    final_filter = filter1 & filter2
    treebase = "ou=People, o=orst.edu"
    ldap_results = ldap.search(:base => treebase, :filter => final_filter)
    if ldap_results.nil?
      return nil
    end
    return ldap_results.sort_by { |u| u.cn }
  end
  
  
  # This method searches the OSU LDAP directory for a given employee by OSU id and ONID username and
  # returns an array with one result. 
  def self.update_search(osu_username, osu_id)
    ldap = Net::LDAP.new :host => "client-ldap.onid.orst.edu", :port => 389
    filter1 = Net::LDAP::Filter.eq("osuuid", osu_id)
    filter2 = Net::LDAP::Filter.eq("uid", osu_username)
    final_filter = filter1 & filter2
    treebase = "ou=People, o=orst.edu"
    ldap_results = ldap.search(:base => treebase, :filter => final_filter)
    if ldap_results.nil?
      return nil
    end
    return ldap_results.sort_by { |u| u.cn }
  end
end

# RemoteEmployee.update_search(Employee.first.osu_username, Employee.first.osu_id).first.uid.first