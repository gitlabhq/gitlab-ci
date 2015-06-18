# Example configuring runner for Ruby

In this example, we configure ruby and mysql for testing environment:

```
# as root
(
set -e
apt-get update
apt-get upgrade -y
apt-get install -y curl
cd /root
rm -rf cookbooks cookbook-gitlab-test.git
curl 'https://gitlab.com/gitlab-org/cookbook-gitlab-test/repository/archive.tar.gz?ref=master' | tar -xvz
mkdir cookbooks
mv cookbook-gitlab-test.git cookbooks/cookbook-gitlab-test
curl -L https://www.chef.io/chef/install.sh | bash
chef-client -z -r 'recipe[cookbook-gitlab-test::ruby], recipe[cookbook-gitlab-test::mysql]'
)


### Register your runner instance with a GitLab CI Coordinator
gitlab-ci-multi-runner register

```