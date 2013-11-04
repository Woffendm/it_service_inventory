if File.exists?(File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper.rb'))
  require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')
else
  require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

  Engines::Testing.set_fixture_path
end

class ActiveSupport::TestCase

  def fixtures_dir
    File.expand_path(File.join(File.dirname(__FILE__), '/fixtures') )
  end

  def reset_fixtures
    if Rails::VERSION::MAJOR >= 3
      ActiveRecord::Fixtures.reset_cache
    else
      Fixtures.reset_cache
    end
  end

  def self.load_my_fixtures(fixtures)
    if Rails::VERSION::MAJOR >= 3
      plugin_create_fixtures( ['projects', 'users', 'versions', 'groups_users', 'settings',
        'members', 'roles', 'member_roles', 'enabled_modules', 'issues', 'trackers', 'issues',
        'projects_trackers', 'issue_statuses', 'enumerations'] )
      plugin_create_fixtures(fixtures)
    end
  end

  def self.plugin_create_fixtures(table_names)
    ActiveRecord::Base.establish_connection(Rails.env.to_sym)
    fixtures_dir = File.join(Rails.root,'test','fixtures')
    table_names.each do |tn|
      if File.exists?(File.join(Rails.root,'plugins','scrum2b','test','fixtures',"#{tn}.yml"))
        ActiveRecord::Fixtures.create_fixtures(File.join(Rails.root,'plugins','scrum2b','test','fixtures'),tn)
      else
        if ActiveRecord::Fixtures.create_fixtures(fixtures_dir, tn).empty?
          puts "Fixture '#{tn}' would not load"
        end
      end
    end

  end

  def set_session_user_id(name)
    unless name.nil?
      case name
        when 'admin'
          @request.session[:user_id] = 1
        when 'manager'
          @request.session[:user_id] = 2
        when 'developer'
          @request.session[:user_id] = 3
        else
          @request.session[:user_id] = name
      end
    end
  end

  def log_user(login, password)
    User.anonymous
    visit "/login"
    fill_in "username", :with => login
    fill_in "password", :with => password
    click_button "Login"
    assert_equal true, page.has_content?("Logged in"), "At 'Logged in'"
  end

  def get_deployment_index_page
    log_user("admin", "admin")
    visit "/projects"
    assert_equal true,page.has_content?("Plugin Development"), "At 'Plugin Development'"

    visit "/projects/plugins_development"
    assert_equal true,page.has_content?("Deployments"), "At 'Deployments'"

    visit "/deployments?project_id=plugins_development"
    assert_equal true, page.has_content?("Deployment Date"), "At 'Deployment Date'"
  end

end
