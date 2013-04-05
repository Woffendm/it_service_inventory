from __future__ import with_statement
from fabric.api import *
from time import localtime, strftime
from fabric.colors import green, red
from fabric.contrib.console import confirm, prompt

#
# This file is used to include specific functions for settings
# that cannot be included within the general fabric script.
# It should include at least the following functions:
# * def app_prompt_user_for_inputs()
# * def app_set_required_environment_vars()
#
# If you don't need to use these, just return from them.
#

# New prompts can sent to the user that set environmental variables for them.
# This can be done using the following syntax:
# utility.prompt_user_for_input(some_environment_name, "What question would you like to ask the user?", default_choice=False)
# The default_choice is what is chosen if the user just hits enter when they see it. It is False by default.
def app_prompt_user_for_inputs():
    return

# Sets unique environmental variables. This can be done with:
# env.my_variable_name = value
def app_set_required_environment_vars():
    env.app_name = "mrg"
    env.repo_name = "multicultural_resource_guide.git"

## Dev
# env.dev_hosts = ['host_name']
# env.dev_path = "/path/to/app/"

## Staging
    env.staging_hosts = ['fab-vd01.cws.oregonstate.edu']
    env.staging_path = "/var/www/%s_code/" % env.app_name

## Production
# env.production_hosts = ['host_name']
# env.production_path = "/path/to/app/"

    env.repo_type = "git"
    env.repo_url = "git@gitlab.cws.oregonstate.edu"

# Array of symlinks to be created to the shared directory.  Each individual symlink is an array
# The first element in the array is the path within the 'shared' directory which we will be
# symlinking to, the second element is the path in the release directory where the symlink will
# be.  If the second element is omitted the path is assumed to be the same in both locations.
    env.custom_symlinks = [
        ['config/app.yml'],
        ['config/prince.yml'],
        ['config/recaptcha.yml'],
        ['config/mrg_config.yml'],
        ['config/logger.yml'],
    ]

    env.project_type = 'rails'

    return
