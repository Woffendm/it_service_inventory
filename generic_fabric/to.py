from fabric.api import *
from fabric.colors import red
from app import *
import config

# This task should be called with ALL other tasks to set an appropriate environment for the
# deployment.  Accept an environment parameter and initialze the env dictionary from values found
# in the config file.
@task
def to(environment=env.default_environment):
    # set configs for the selected environment
    env.hosts = env["%s_hosts" % environment]
    env.path = env["%s_path" % environment]
    env.releases_path = env.path + "releases/"
    env.shared_path = env.path + "shared/"
    env.backups_path = env.path + "backups/"


    # set a flag to show to has been executed
    env.deploy_to = environment


def abort_if_no_environment():
    if (env.deploy_to == ""):
        abort(red("No environment has been set.  All calls should begin with 'fab to:environment'"))
