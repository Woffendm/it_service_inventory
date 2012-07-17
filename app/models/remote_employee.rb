# This class is used to search the OSU LDAP directory for a given employee and return an array of
#    results
#
# Author: Michael Woffendin 
# Copyright:

class RemoteEmployee
  
  # This 
  def self.search(employee_name)
    ldap = Net::LDAP.new :host => "client-ldap.onid.orst.edu", :port => 389
    filter = Net::LDAP::Filter.eq("cn", employee_name.to_s + "*")
    treebase = "ou=People, o=orst.edu"
    ldap_results = ldap.search(:base => treebase, :filter => filter)
    if ldap_results.nil?
      return nil
    end
    return ldap_results.sort_by { |u| u.cn }
  end
  
end