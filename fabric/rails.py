from __future__ import with_statement
from fabric.api import *
from time import localtime, strftime
from fabric.colors import green, red
from fabric.contrib.console import confirm, prompt

from config import *
from to import *
from utility import *

# Run migrations
@task
def migrate(version=""):
    command = "db:migrate"
    if (version != ""):
        command = command + " VERSION=" + version
    rake(command)


# Run a rake task
@task
def rake(command):
    # If we don't have a release path, assume we are running on the 'current' version
    if ("release_path" not in env):
        build_release_path(True)

    rake_command = "rake " + command

    if (env.rake_via_bundler):
        rake_command = "bundle exec " + rake_command

    rake_command = rake_command + " RAILS_ENV=production"

    if (env.rvm != ""):
        rvm_command = "source /home/%s/.bashrc && source %s && rvm reload && " % (env.user, env.rvm)
        rake_command = rvm_command + rake_command

    with cd(env.release_path):
        run(rake_command)
        print(green("Rake command: " + rake_command + " finished."))

# Run a bundle task
@task
def bundle(bundle_command):
    # If we don't have a release path, assume we are running on the 'current' version
    if ("release_path" not in env):
        build_release_path(True)

    bundle_command = "bundle " + bundle_command
    if (env.rvm != ""):
        rvm_command = "source /home/%s/.bashrc && source %s && rvm reload && " % (env.user, env.rvm)
        bundle_command = rvm_command + bundle_command

    with cd(env.release_path):
        run("rm -rf .bundle")
        run("rm -f Gemfile.lock")
        run(bundle_command)
        print(green("Bundle command: " + bundle_command + " finished."))


# Restart the server, by touching tmp/restart.txt
def rails_restart():
    run("sudo touch %scurrent/tmp/restart.txt" % env.path)
    print(green("Application Restarted (touched tmp/restart.txt)"))

# Goes through functions required to set up a new rails project
# These functions may or may not run, depening on what users chose
# to run at the start of the deployment
def rails_project_setup():
    if (env.use_rvm):
        install_rvm()

    if (env.bundle_gems):
        if (env.rvm != ""):
            bundle("install --without='development test' ")
        else:
            bundle("install --without='development test' --path=bundle")

    if (env.run_migrations):
        migrate()

    if (env.run_seed_task):
        rake("db:seed")

    if (env.run_seed_fu_task):
        rake("db:seed_fu")

    if (env.precompile_assets):
        rake("assets:precompile")

# Install rvm under user
@task
def install_rvm():
    # Get out of here if environment is not set
    abort_if_no_environment()

    set_required_environment_vars()

    # # Run deployment methods
    build_release_path()

    print green("Ready to install rvm to %s" % env.rvm)

    run("\curl -L https://get.rvm.io | bash -s stable")
    run("echo 'PATH=$HOME/.rvm/bin:$PATH # Add RVM to PATH for scripting' >> .bashrc")
    run("/home/%s/.rvm/bin/rvm install %s-p%s" % (env.app_user, env.ruby_version, env.ruby_patch_level))
    run("/home/%s/.rvm/bin/rvm alias create default %s-p%s" % (env.app_user, env.ruby_version, env.ruby_patch_level))
    run("echo 'source \"$HOME/.rvm/scripts/rvm\"' >> .bash_profile")
    run("gem install bundler")
    run("gem install passenger -v %s" % env.passenger_version)
    sudo("rm -f /etc/httpd/conf.d/passenger.conf")
    sudo("/home/%s/.rvm/bin/ruby  /home/appuser/.rvm/gems/ruby-%s-p%s/bin/passenger-install-apache2-module -a" \
       % (env.app_user, env.ruby_version, env.ruby_patch_level))

# Checks to see if rvm is install and path is setup
@task
def check_rvm():
    # Get out of here if environment is not set
    abort_if_no_environment()

    set_required_environment_vars()

    # # Run deployment methods
    build_release_path()

    run("rvm list")
    run("which gem")
    run("echo $PATH")
    run("source .bash_profile; which passenger-install-apache2-module")
    run("source .rvm/scripts/rvm; rvm list")
    run("source .rvm/scripts/rvm; ruby --version")
    run("source .bashrc; ruby --version")
    run("source .bashrc; bundle")

