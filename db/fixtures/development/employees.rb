Employee.seed_once(:id,
  { :id => 1, :name_first => "Michael", :name_last => "Woffendin", :osu_username => "woffendm",   :site_admin => true  },
  { :id => 2, :name_first => "Matthew", :name_last => "Hansen", :osu_username => "hansenm",   :site_admin => true  },
  { :id => 3, :name_first => "Jos", :name_last => "Accapadi", :osu_username => "accapadj",   :site_admin => true  }
)

@names = ["Bob", "Joe", "Smith", "Karren", "Megan", "Rachel", "Sean", "Donald", "John", "Stephen", "Doe", "West", "Charlie", "Bacon"]
@names.each do |first_name|
  @names.each do |last_name|
    Employee.seed_once do |t|
      t.name_first = first_name
      t.name_last = last_name
    end
  end
end