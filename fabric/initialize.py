from __future__ import with_statement
from fabric.api import *
from fabric.colors import red, green, yellow
from fabric.contrib.files import exists

from to import *
from utility import is_rails_project, create_dir

# This method is responsible for initial directory setup.  App structure is assumed to be:
# /path/to/app/
#   releases/   - directory containing individual releases
#   shared/     - directory containing things shared amongst releases such as config and log files
#   current     - symlink pointing to the current release
@task
def initialize():
    # If no environment is set get out of here
    abort_if_no_environment()

    # Ensure the releases directory exists
    if (not exists(env.releases_path)):
        with cd (env.path):
            run("mkdir releases")

    # Ensure the shared directory exists
    if (not exists(env.shared_path)):
        create_dir(env.path, env.shared_directory_name)
        create_dir(env.path, "%s/%s" % (env.shared_directory_name, env.shared_config_directory_name))
        create_dir(env.path, env.backups_directory_name)
        print green("Application directories set up at %s.\nYou can deploy the application using fab to:%s deploy." % (env.path, env.deploy_to))
        if is_rails_project():
            create_dir(env.path, "%s/%s" % (env.shared_directory_name, env.shared_bundle_directory_name))
            create_dir(env.path, "%s/%s" % (env.shared_directory_name, env.shared_tmp_directory_name))
            create_dir(env.path, "%s/%s" % (env.shared_directory_name, env.shared_logs_directory_name))
            run ("touch %s/%s/%s/production.log" %(env.path, env.shared_directory_name, env.shared_logs_directory_name))
            print yellow("Upload database.yml and other .yml files to %s/%s/%s." % (env.path, env.shared_directory_name, env.shared_config_directory_name))

