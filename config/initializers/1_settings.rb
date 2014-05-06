class Settings < Settingslogic
  source "#{Rails.root}/config/application.yml"
  namespace Rails.env

  class << self
    def gitlab_ci_on_non_standard_port?
      ![443, 80].include?(gitlab_ci.port.to_i)
    end

    private

    def build_gitlab_ci_url
      if gitlab_ci_on_non_standard_port?
        custom_port = ":#{gitlab_ci.port}"
      else
        custom_port = nil
      end
      [ gitlab_ci.protocol,
        "://",
        gitlab_ci.host,
        custom_port,
        gitlab_ci.relative_url_root
      ].join('')
    end
  end
end


#
# GitlabCi
#
Settings['gitlab_ci'] ||= Settingslogic.new({})
Settings.gitlab_ci['https']               = false if Settings.gitlab_ci['https'].nil?
Settings.gitlab_ci['host']                ||= 'localhost'
Settings.gitlab_ci['port']                ||= Settings.gitlab_ci.https ? 443 : 80
Settings.gitlab_ci['relative_url_root']   ||= ENV['RAILS_RELATIVE_URL_ROOT'] || ''
Settings.gitlab_ci['protocol']            ||= Settings.gitlab_ci.https ? "https" : "http"
Settings.gitlab_ci['email_from']          ||= "gitlab-ci@#{Settings.gitlab_ci.host}"
Settings.gitlab_ci['support_email']       ||= Settings.gitlab_ci.email_from
Settings.gitlab_ci['all_broken_builds'] = true if Settings.gitlab_ci['all_broken_builds'].nil?
Settings.gitlab_ci['add_committer']     = false if Settings.gitlab_ci['add_committer'].nil?
Settings.gitlab_ci['url']                 ||= Settings.send(:build_gitlab_ci_url)

# Compatibility with old config
Settings['gitlab_server_urls'] ||= Settings['allowed_gitlab_urls']

#
# Gravatar
#
Settings['gravatar'] ||= Settingslogic.new({})
Settings.gravatar['enabled']     = true if Settings.gravatar['enabled'].nil?
Settings.gravatar['plain_url'] ||= 'http://www.gravatar.com/avatar/%{hash}?s=%{size}&d=mm'
Settings.gravatar['ssl_url']   ||= 'https://secure.gravatar.com/avatar/%{hash}?s=%{size}&d=mm'
