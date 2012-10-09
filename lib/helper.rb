module Helper
  JS_ESCAPE_MAP = {
    '\\'    => '\\\\',
    '</'    => '<\/',
    "\r\n"  => '\n',
    "\n"    => '\n',
    "\r"    => '\n',
    '"'     => '\\"',
    "'"     => "\\'"
  }

  def project_statuc_class(project)
    if project.status == 'success'
      'alert-success'
    elsif project.status == 'fail'
      'alert-error'
    else
      ''
    end
  end

  def build_status_class build
    if build.success?
      'label-success'
    elsif build.failed?
      'label-important'
    else
      'label-inverse'
    end
  end

  def build_status_alert_class build
    if build.success?
      'alert-success'
    elsif build.failed?
      'alert-error'
    else
      ''
    end
  end

  def run_project_path project
    "/projects/#{project.name}/run"
  end

  def project_path project
    "/projects/#{project.name}"
  end

  def edit_project_path project
    "/projects/#{project.name}/edit"
  end

  def build_path build
    "/builds/#{build.id}"
  end

  def escape_javascript(javascript)
    if javascript
      result = javascript.gsub(/(\\|<\/|\r\n|\342\200\250|[\n\r"'])/u) {|match| JS_ESCAPE_MAP[match] }
    else
      ''
    end
  end
end
