from fabric.api import env # importing to make the env dict available

from app import *
from utility import is_rails_project

# This will force password prompting and skip looking for ssh keys
env.no_keys = False

# Set the user to have permission on directories for initial installation
env.user = "appuser"

# Set the user for the applicaition after installation
env.app_user = "appuser"

# Set the user that the web server runs as
# Centos 6 environment
env.web_user = "apache"
env.web_server_name = "httpd"
env.web_config_directory = "/etc/httpd/conf.d"

# Debian environment
# env.web_user = "www-data"
# env.web_server_name = "apache2"
# env.web_config_directory = "/etc/apache2/sites-enabled"

# Project type
env.project_type = ''

# Repository settings for the application.  Supported repository types: svn, git
env.repo_type = ""
env.repo_url = ""
env.repo_name = ""
env.release = ""

# Number of releases to keep (Any amount after this one is deleted)
env.past_releases_to_keep = 3

# Number of backups to keep (Any amount after this one is deleted)
env.past_backups_to_keep = 3

# Directory names that structure the releases. These shouldn't have to be changed.
env.shared_directory_name = 'shared'
env.shared_config_directory_name = 'config'
env.backups_directory_name = 'backups'
env.all_releases_directory_name = 'releases'
env.current_release_directory_name = 'current'

# holds the value of the environment we are deploying to, initialized to empty for checking in script
env.deploy_to = ""

# default environmnet to deploy to, if set to "" the user will be forced to supply an environment
env.default_environment = "dev"

# Rails variables which may be set by the application
env.rvm = ""

# Set the application specific variables
# Later variables may change based on settings in app.py as well as settings
# in app.py using variables in this file
app_set_required_environment_vars()

# Variables dependent on possible app settings
if env.repo_type == 'git':
    env.repo_path = "%s:%s" % (env.repo_url, env.repo_name)
else:
    env.repo_path = "%s %s" % (env.repo_url, env.repo_name)

# Array of symlinks to be created to the shared directory.  Each individual symlink is an array
# The first element in the array is the path within the 'shared' directory which we will be
# symlinking to, the second element is the path in the release directory where the symlink will
# be.  If the second element is omitted the path is assumed to be the same in both locations.
if is_rails_project():
    env.release_symlinks = [
      ['config/database.yml'],
      ['log'],
      ['bundle'],
      ['tmp'],
    ]
    # Rails flags
    env.rake_via_bundler = True
    env.shared_bundle_directory_name = 'bundle'
    env.shared_tmp_directory_name = 'tmp'
    env.shared_logs_directory_name = 'log'
else:
    env.release_symlinks = [
      ['tmp'],
    ]
