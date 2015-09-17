# Change this to true if you want some prepopulated users
run = false

if run
  Employee.seed_once(
    {:first_name => "admin",  :last_name => "admin", :middle_name => "admin", :email => "admin@admin.admin",
      :uid => "admin", :osu_id => "admin", :site_admin => true},
    {:first_name => "Big",  :last_name => "Bob", :middle_name => "", :email => "big.bob@bobbing4apples.com",
      :uid => "bob", :osu_id => "bob", :site_admin => false},  
    {:first_name => "Frank",  :last_name => "Beans", :middle_name => "", :email => "i_love_beans@gmail.com",
      :uid => "frankybeans", :osu_id => "frankbeans123", :site_admin => false},
    {:first_name => "Susie",  :last_name => "Q", :middle_name => "", :email => "susieq@gmail.com",
      :uid => "susie", :osu_id => "susie", :site_admin => false}
  )
end