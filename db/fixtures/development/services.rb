@service_starters = ["Rails", "Java", "PHP", "Drupal", "Mobile", "Python", "CMS"]
@service_starters_2 = ["Application Stack", "Database", "CMS", "Automation", "Linux", "Management", 
                       "Windows", "Virtualization"]
@service_enders = ["Administration", "Development"]

@service_starters.each do |starter|
  Service.seed_once do |t|
    t.name = starter + @service_enders[0]
  end
end

@service_starters_2.each do |starter|
  Service.seed_once do |t|
    t.name = starter + @service_enders[1]
  end
end