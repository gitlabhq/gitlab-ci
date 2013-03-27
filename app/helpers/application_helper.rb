module ApplicationHelper
  def loader_html
    image_tag 'loader.gif'
  end

  def ldap_enable?
    Devise.omniauth_providers.include?(:ldap)
  end
end
