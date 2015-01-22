module IconsHelper
  def boolean_to_icon(value)
    if value.to_s == "true"
      content_tag :i, nil, class: 'icon-circle cgreen'
    else
      content_tag :i, nil, class: 'icon-power-off clgray'
    end
  end
end
