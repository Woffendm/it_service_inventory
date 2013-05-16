task :default => :testing

                                                                                                    

task :testing do
  Rake::Task["spec"].invoke
  Rake::Task["test"].invoke
end
