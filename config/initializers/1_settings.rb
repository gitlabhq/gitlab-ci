class Settings < Settingslogic
  source "#{Rails.root}/config/gitlab-ci.yml"
  namespace Rails.env
end

# Default settings
Settings['ldap']                ||= Settingslogic.new({})
Settings.ldap['enabled']          = false if Settings.ldap['enabled'].nil?

Settings['omniauth']            ||= Settingslogic.new({})
Settings.omniauth['enabled']      = false if Settings.omniauth['enabled'].nil?
Settings.omniauth['providers']  ||= []

#
# GitLab Ci
#
Settings['gitlab_ci']            ||= Settingslogic.new({})
Settings.gitlab_ci['user']       ||= 'gitlab_ci'
Settings.gitlab_ci['email_from'] ||= 'please-change-me-at-config-gitlab-ci_yml@example.com'

puts Settings.ldap.enabled
