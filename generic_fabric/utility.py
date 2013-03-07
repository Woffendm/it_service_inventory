from __future__ import with_statement
from fabric.api import *
from time import localtime, strftime
from fabric.colors import green, red
from fabric.contrib.console import confirm, prompt
from fabric.contrib.files import exists

from config import *

# Build the release path based on the current link or a timestamp
def build_release_path(use_current=False):
    if (use_current):
        # Get the current release
        path = run("file %scurrent | awk '{print $5}'" % env.path)
        env.release = path.split("/")[-2]
    else:
        # set a timestamp for this release
        if env.release == '':
          env.release = strftime("%Y%m%d%H%M", localtime())

    # set the release path for this release
    env.release_path = env.releases_path + env.release + "/"
    create_dir(env.releases_path, env.release)


# This method will create symlinks to files in the shared directory.  It uses the
# release_symlinks array in the config file to determine what to symlink
def symlink_configs():
    for symlink in env.release_symlinks:
        # Get the source and destination, if there is no destination it is assumed to be
        # the same as source
        source = symlink[0]
        if (len(symlink) > 1):
            destination = symlink[1]
        else:
            destination = symlink[0]

        link(env.shared_path + source, env.release_path + destination)

    for symlink in env.custom_symlinks:
        # Get the source and destination, if there is no destination it is assumed to be
        # the same as source
        source = symlink[0]
        if (len(symlink) > 1):
            destination = symlink[1]
        else:
            destination = symlink[0]

        link(env.shared_path + source, env.release_path + destination)


# Take a source and destination, create a symlink
def link(source, destination):
    run("ln -nfs %s %s" % (source, destination))


# Update current symlink to point to the new release
def set_current(release_path=''):
    # Default to env.release_path
    if(release_path == ""):
        release_path = env.release_path

    # set the current symlink to point to our new release
    link(release_path, env.path + 'current')

# Make a specified directory web writable
@task
def make_web_writable(path):
    sudo("setfacl -R -m d:u:%(user)s:rwx,u:%(user)s:rwx %(path)s" \
        % {"user": env.app_user, "path": path})


# This method is used for setting application permissions.  It is declared as a task so that
# permissions can easily be restored without performing a full deployment
@task
def set_permissions():
    # If we don't have a release path, assume we are running on the 'current' version
    if ("release_path" not in env):
        build_release_path(True)

    # Ensure we have the proper owner and group on all our stuff
    sudo("chown -R %(user)s:%(user)s %(path)s" \
      % {"user": env.app_user, "path": env.release_full_path})
    sudo("chown -R %(user)s:%(user)s %(path)s" \
     % {"user": env.app_user, "path": env.shared_path})

    # Ensure we have the proper mode set on our stuff
    sudo("chmod -R 0700 %s" % env.release_path)
    sudo("chmod -R 0700 %s" % env.shared_path)

    # Stop passenger from whining
    sudo("chmod 0666 %slog/production.log" % env.shared_path)

    # Scrub all existing ACLS
    sudo("setfacl -R -b %s" % env.release_path)
    sudo("setfacl -R -b %s" % env.shared_path)

    # Give application user rX on full app (release path and shared path)
    sudo("setfacl -R -m d:u:%(user)s:rx,u:%(user)s:rx %(path)s" \
        % {"user": env.app_user, "path": env.release_path})

    sudo("setfacl -R -m d:u:%(user)s:rx,u:%(user)s:rx %(path)s" \
        % {"user": env.app_user, "path": env.shared_path})

    # Give the app user rwX on tmp and log
    make_web_writable("%s%s" % (env.release_path, env.shared_tmp_directory_name))
    make_web_writable("%s%s" % (env.shared_path, env.shared_logs_directory_name))

    # Give www-data rX on root of app and public
    sudo("setfacl -R -m d:u:%s:rx,u:%s:rx %s" % (env.app_user, env.app_user, env.release_path))

    # At this point, we need to give www-data access to the release, so you can get there on the web
    sudo("setfacl -R -m d:u:%s:rx,u:%s:rx %s" % (env.web_user, env.web_user, env.release_path))
    # give apache_user rX on root of app and public
    sudo("setfacl -m u:%s:rx %s" % (env.web_user, env.release_full_path))
    sudo("setfacl -R -m d:u:%(user)s:rx,u:%(user)s:rx %(path)s/public" \
      % {"user": env.web_user, "path": env.release_full_path})


# Prompts the user to input what they want to do later.
# This allows the user to choose everything they want to
# do before we begin the lengthy checkout itself
def prompt_user_for_inputs():
    if (env.repo_type == "svn"):
      env.repo = prompt("Svn: Branch, tag, trunk?")

    if (env.repo_type == "git"):
      env.checkout = prompt(red("Git: What tag/branch would you like to checkout?"))

    prompt_user_for_input("backup_database", "Backup database?")

    if is_rails_project():
        prompt_user_for_input('use_rvm', "Use rvm?")
        prompt_user_for_input('bundle_gems', "Bundle gems?")
        prompt_user_for_input('run_migrations', "Run migrations?")
        prompt_user_for_input('run_seed_task', "Run seed task?")
        prompt_user_for_input('run_seed_fu_task', "Run seed_fu task?")
        prompt_user_for_input('precompile_assets', "Precompile assets?")

# Prompts the user for a single input, and sets the provided environment variable for it
def prompt_user_for_input(environment_var_name, prompt_string, default_choice=False):
  input = confirm(red(prompt_string), default=default_choice)
  env[environment_var_name] = input

# Temporarily grants rights to the deploying user to the shared directory
# This allows them to run rake, run scripts, etc.
def grant_user_rights_to_shared_files():
#    sudo("setfacl -m d:u:%s:rwx,u:%s:rwx %s" % (env.user, env.user, env.shared_full_path))
    sudo("setfacl -R -m d:u:%s:rwx,u:%s:rwx %s" % (env.user, env.user, env.config_full_path))

# Sets a bunch of variables we'll need during the deploy
# This will allow us to change them in one place
def set_required_environment_vars():
    env.deploy_hosts = env["%s_hosts" % env.deploy_to]
    env.deploy_path = env["%s_path" % env.deploy_to]
    env.shared_full_path = "%s%s" % (env.deploy_path, env.shared_directory_name)
    env.config_full_path = "%s/%s" % (env.shared_full_path, env.shared_config_directory_name)
    env.tmp_full_path = "%s/%s" % (env.shared_full_path, env.shared_tmp_directory_name)
    env.log_full_path = "%s/%s" % (env.shared_full_path, env.shared_logs_directory_name)
    env.all_releases_full_path = "%s%s" % (env.deploy_path, env.all_releases_directory_name)
    env.current_release_full_path = "%s%s" % (env.deploy_path, env.current_release_directory_name)
    env.release_path = strftime("%Y%m%d%H%M", localtime())
    env.release_full_path = "%s/%s" % (env.all_releases_full_path, env.release_path)
    env.release_file_upload_full_path = "%s/public" % env.release_full_path
    # Forces the environment to not use shells
    # This is used to make it so when running sudo commands, Fabric
    # will only run the command, and not try and run it in bash
    # We set this to get around the problem of not being able to run
    # bash as the sudo user.
    # env.use_shell = False

def is_rails_project():
    return (env.project_type == 'rails')

# Creates a supplied dierctory if it does not exist.
def create_dir(current_directory, dir_to_create):
  if current_directory == '':
    dir_to_create_full_path = "%s" % dir_to_create
  else:
    dir_to_create_full_path = "%s/%s" % (current_directory, dir_to_create)
  if not exists(dir_to_create_full_path):
    run("mkdir %s" % dir_to_create_full_path)


# Restart web server
def restart_webserver():
    sudo("/etc/init.d/%s restart" % env.web_server_name)
