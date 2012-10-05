module Helper
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
end
