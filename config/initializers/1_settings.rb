class Settings < Settingslogic
  source "#{Rails.root}/config/application.yml"
  namespace Rails.env
end


#
# GitlabCi
#
Settings['gitlab_ci'] ||= Settingslogic.new({})
Settings.gitlab_ci['https'] = false if Settings.gitlab_ci['https'].nil?

#
# Gravatar
#
Settings['gravatar'] ||= Settingslogic.new({})
Settings.gravatar['enabled']     = true if Settings.gravatar['enabled'].nil?
Settings.gravatar['plain_url'] ||= 'http://www.gravatar.com/avatar/%{hash}?s=%{size}&d=mm'
Settings.gravatar['ssl_url']   ||= 'https://secure.gravatar.com/avatar/%{hash}?s=%{size}&d=mm'
