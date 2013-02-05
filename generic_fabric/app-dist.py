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


# Does application specific setup of what ever is not covered by the generic fabric script.
def app_setup():
    return


# Sets unique environmental variables. This can be done with:
# env.my_variable_name = value
def app_set_required_environment_vars():
    env.app_name = ""
    env.repo_name = ""

## Dev
# env.dev_hosts = ['host_name']
# env.dev_path = "/path/to/app/"

## Staging
#    env.staging_hosts = ['host_name']
#    env.staging_path = "/var/www/%s_code/" % env.app_name

## Production
# env.production_hosts = ['host_name']
# env.production_path = "/path/to/app/"

#    env.repo_type = "git"
#    env.repo_url = "git@host_name"

# Array of symlinks to be created to the shared directory.  Each individual symlink is an array
# The first element in the array is the path within the 'shared' directory which we will be
# symlinking to, the second element is the path in the release directory where the symlink will
# be.  If the second element is omitted the path is assumed to be the same in both locations.
    env.custom_symlinks = [
    ]

#    env.project_type = 'rails'

# Variables for rvm installation
#
# Note that the versions for passenger and ruby version and patch level must match what is in the 
# httpd config file.

# Ruby version
#     env.ruby_version = "1.9.3"

# RVM path
#     env.rvm = "/home/%s/.rvm/scripts/rvm" % env.user

# Passenger version
#     env.passenger_version = "3.0.18"

# Ruby patch level
#     env.ruby_patch_level = "362"


    return
