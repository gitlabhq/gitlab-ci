module ApplicationHelper
  def loader_html
    image_tag 'loader.gif'
  end

  def gravatar_icon(user_email = '', size = nil)
    size = 40 if size.nil? || size <= 0

    if !GitlabCi.config.gravatar.enabled || user_email.blank?
      'no_avatar.png'
    else
      gravatar_url = request.ssl? || GitlabCi.config.gitlab_ci.https.enabled ? GitlabCi.config.gravatar.ssl_url : GitlabCi.config.gravatar.plain_url

      user_email.strip!
      sprintf gravatar_url, hash: Digest::MD5.hexdigest(user_email.downcase), size: size
    end
  end
  # Navigation link helper
  #
  # Returns an `li` element with an 'active' class if the supplied
  # controller(s) and/or action(s) are currently active. The content of the
  # element is the value passed to the block.
  #
  # options - The options hash used to determine if the element is "active" (default: {})
  #           :controller   - One or more controller names to check (optional).
  #           :action       - One or more action names to check (optional).
  #           :path         - A shorthand path, such as 'dashboard#index', to check (optional).
  #           :html_options - Extra options to be passed to the list element (optional).
  # block   - An optional block that will become the contents of the returned
  #           `li` element.
  #
  # When both :controller and :action are specified, BOTH must match in order
  # to be marked as active. When only one is given, either can match.
  #
  # Examples
  #
  #   # Assuming we're on TreeController#show
  #
  #   # Controller matches, but action doesn't
  #   nav_link(controller: [:tree, :refs], action: :edit) { "Hello" }
  #   # => '<li>Hello</li>'
  #
  #   # Controller matches
  #   nav_link(controller: [:tree, :refs]) { "Hello" }
  #   # => '<li class="active">Hello</li>'
  #
  #   # Shorthand path
  #   nav_link(path: 'tree#show') { "Hello" }
  #   # => '<li class="active">Hello</li>'
  #
  #   # Supplying custom options for the list element
  #   nav_link(controller: :tree, html_options: {class: 'home'}) { "Hello" }
  #   # => '<li class="home active">Hello</li>'
  #
  # Returns a list item element String
  def nav_link(options = {}, &block)
    if path = options.delete(:path)
      if path.respond_to?(:each)
        c = path.map { |p| p.split('#').first }
        a = path.map { |p| p.split('#').last }
      else
        c, a, _ = path.split('#')
      end
    else
      c = options.delete(:controller)
      a = options.delete(:action)
    end

    if c && a
      # When given both options, make sure BOTH are active
      klass = current_controller?(*c) && current_action?(*a) ? 'active' : ''
    else
      # Otherwise check EITHER option
      klass = current_controller?(*c) || current_action?(*a) ? 'active' : ''
    end

    # Add our custom class into the html_options, which may or may not exist
    # and which may or may not already have a :class key
    o = options.delete(:html_options) || {}
    o[:class] ||= ''
    o[:class] += ' ' + klass
    o[:class].strip!

    if block_given?
      content_tag(:li, capture(&block), o)
    else
      content_tag(:li, nil, o)
    end
  end

  # Check if a particular controller is the current one
  #
  # args - One or more controller names to check
  #
  # Examples
  #
  #   # On TreeController
  #   current_controller?(:tree)           # => true
  #   current_controller?(:commits)        # => false
  #   current_controller?(:commits, :tree) # => true
  def current_controller?(*args)
    args.any? { |v| v.to_s.downcase == controller.controller_name }
  end

  # Check if a particular action is the current one
  #
  # args - One or more action names to check
  #
  # Examples
  #
  #   # On Projects#new
  #   current_action?(:new)           # => true
  #   current_action?(:create)        # => false
  #   current_action?(:new, :create)  # => true
  def current_action?(*args)
    args.any? { |v| v.to_s.downcase == action_name }
  end

  def date_from_to(from, to)
    "#{from.to_s(:short)} - #{to.to_s(:short)}"
  end
end
