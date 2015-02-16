
# How you build script is run

The runner runs the line below before it runs the commands in your build script:

    cd /gitlab-ci-runner/tmp/builds && git clone git@gitlab_server_fqdn:group/project.git project-1 && cd project-1 && git checkout master

# Build script example

    bundle install
    bundle exec rake db:create RAILS_ENV=test
    bundle exec rake db:migrate RAILS_ENV=test
    script/run_all_tests

# Environmental variables

The build command is run from [GitlabCi::Build#command](https://gitlab.com/gitlab-org/gitlab-ci-runner/blob/master/lib/build.rb#L96) and contains the following environmental variables:

    CI_SERVER, CI_SERVER_NAME, CI_SERVER_VERSION, CI_SERVER_REVISION
    CI_BUILD_REF, CI_BUILD_BEFORE_SHA, CI_BUILD_REF_NAME (branch), CI_BUILD_ID

# Build script examples

+ [Build script for Omniauth LDAP](build-script-for-omniauth-ldap.md)
+ [Build script GitLab CE](build_script_gitlab_ce.md)
+ [Build script for Sencha deploy PhoneGapBuild](build_script_sencha_deploy_phonegapbuild.md)

# Configuring a runner example

+ [Configure a runner to run the GitLab CE test suite](configure_a_runner_to_run_the_gitlab_ce_test_suite.md)
