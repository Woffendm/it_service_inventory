from __future__ import with_statement
from fabric.api import *
from fabric.colors import green, red
from fabric.decorators import *
from fabric.operations import *
from time import localtime, strftime

import config
from backup import *
from checkout import *
from to import *
from initialize import *
from utility import *
from rails import *

# This method should execute everything needed for a full deploy
@task
def deploy():
    # Get out of here if environment is not set
    abort_if_no_environment()

    prompt_user_for_inputs()
    set_required_environment_vars()

    # # Run deployment methods
    build_release_path()
    checkout()
    grant_user_rights_to_shared_files()
    symlink_configs()

    if (env.backup_database):
        backup()

    if is_rails_project():
        rails_project_setup()

    app_setup()
    # # Create a symlink to the files directory (Fileship specific)
    # link(env.symlink_upload_directory, ('%s/public/uploads' % env.release_full_path))
    # link(env.tmp_full_path, ('%s/%s' % (env.release_full_path, env.shared_tmp_directory_name)))
    # # Link the log directory - to link it, we first must remove the /log directory
    # run("sudo rm -rf %s/%s" % (env.release_full_path, env.shared_logs_directory_name))
    # link(env.log_full_path, ('%s/%s' % (env.release_full_path, env.shared_logs_directory_name)))
    set_permissions()
    # # Give the app user rwX on the uploads directory (Fileship specific)
    # run("sudo setfacl -m u:%s:rwX %s" % (env.app_user, env.shared_full_path))
    # run("sudo setfacl -m u:%s:rwX %s" % (env.app_user, env.symlink_upload_directory))
    set_current()
    restart()

# This method should be used to rollback the application.  It accepts a version to rollback to
# if a version is not provided the user will be shown a list of available rollback points
# and prompted to choose one
@task
def rollback(version = ''):
    build_release_path()
    set_required_environment_vars()
    # If the user didn't pass a version, show the list and prompt them for one
    if (version == ''):
        run("ls %s" % env.releases_path)
        version = prompt("Which release would you like to rollback to?")

    # If the specified version exists set it to current, otherwise display an error message
    if (exists(env.releases_path + version)):
        set_current("%s/%s" % (env.releases_path, version))
        restart()
        print(green("Rolled back to version: " + version))
    else:
        print(red("You have not specified a valid version"))

    if confirm("Restore database?", default=False):
        run("ls %s" % env.backups_path)
        version = prompt("Which release would you like to rollback to?")

        if (exists("%s/%s" % (env.backups_path,  version))):
           if is_rails_project():
             restore_rails_database(version)

# Restart the application
@task
def restart():
    if is_rails_project():
        rails_restart()
    else:
        restart_webserver()

