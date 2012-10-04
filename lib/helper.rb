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

  def project_path project
    "/projects/#{project.name}"
  end

  def edit_project_path project
    "/projects/#{project.name}/edit"
  end
end
