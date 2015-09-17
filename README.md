# it_service_inventory

Requires mysql2 and libmysqlclient-dev installed on the machine.

Requires ruby 1.9.3 and bundler to be installed. I also recommend using RVM.

Be sure to run "bundle install" first.

In the config directory be sure to rename both of the .yml-dist file extensions to .yml and populate them with your data.

Install the database:
* rake db:create
* rake db:migrate
* rake db:seed_fu

Start the rails server (rails s).


Suggestions for testing out the app: 
* Edit the file dv/fixtures/employees.rb and set 'run' to true. This will create some users without needing LDAP (However certain parts of the app will be broken without proper LDAP configuration)
* Go to localhost:3000/logins/new_backdoor, type in 'admin', and click the login button to become an admin.
* You can use the aforementioned URL to log in as any existing user without authenticating.
