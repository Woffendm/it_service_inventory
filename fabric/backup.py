from __future__ import with_statement
from fabric.api import *
from fabric.colors import red, green

import config
from utility import create_dir, build_release_path, set_required_environment_vars, is_rails_project
from to import abort_if_no_environment

# Backup database
@task
def backup():
    # Get out of here if environment is not set
    abort_if_no_environment()

    # Run deployment methods
    set_required_environment_vars()
    build_release_path()
    if is_rails_project():
        backup_rails_database()
    else:
        backup_database()

    cleanup_backups()



# Backup the database
def backup_rails_database():
    db_info = get_rails_db_info()
    create_dir(env.backups_path, env.release)
    with hide('running', 'stdout', 'stderr'):
        run("mysqldump -h %s -u %s -p%s %s > %s/%s/%s.dump" \
             % (db_info.get('host'), db_info.get('user'), db_info.get('password'), \
                db_info.get('database'), env.backups_path, env.release, env.app_name))
        puts("mysqldump -h %s -u %s -p<PASSWORD> %s > %s/%s/%s.dump" \
             % (db_info.get('host'), db_info.get('user'), db_info.get('database'), env.backups_path, env.release, env.app_name))

# Retore the database
def restore_rails_database(version):
    db_info = get_rails_db_info()
    database_path = run("ls %s/%s" % (env.backups_path, version))
    if (database_path == ""):
        abort(red("No previous backup: cannot restore system"))
    with hide('running', 'stdout', 'stderr'):
        run("mysql -h %s -u %s -p%s %s < %s/%s/%s.dump" \
             % (db_info.get('host'), db_info.get('user'), db_info.get('password'), \
                db_info.get('database'), env.backups_path, env.release, env.app_name))
        puts("mysql -h %s -u %s -p<PASSWORD> %s < %s/%s/%s.dump" \
             % (db_info.get('host'), db_info.get('user'), db_info.get('database'), env.backups_path, env.release, env.app_name))

# If there are more than 3, get rid of the oldest
def cleanup_backups():
    # If there are more than 3, remove the oldest
    dirs = run("ls %s" % env.backups_path).split("  ")
    if (len(dirs) > env.past_backups_to_keep):
        dirs = sorted(dirs)
        with cd(env.backups_path):
            sudo("rm -rf " + dirs[0] + "/")
            print(green("Deleting old backup: %s" % dirs[0]))


# Backup generic (PHP?) database
def backup_database():
    return


# Return the username, host, password and database name of a rails config/database.yml
# Note: it returns the values from the first entry
# Hide is used to prevent exposure of database password
def get_rails_db_info():
    user = run("grep username %s/database.yml |awk -F: '{print $2}'|head -n 1" % env.config_full_path)
    host = run("grep host %s/database.yml |awk -F: '{print $2}'|head -n 1" % env.config_full_path)
    with hide('running', 'stdout', 'stderr'):
        password = run("grep password %s/database.yml |awk -F: '{print $2}'|head -n 1" % env.config_full_path)
    database = run("grep database %s/database.yml |awk -F: '{print $2}'|head -n 1" % env.config_full_path)
    return {'user': user, 'password': password, 'host': host, 'database': database}
