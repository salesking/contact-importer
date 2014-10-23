module ApplicationHelper
	def icon(icon_link)
    "<i class=\"fa fa-#{icon_link}\"></i>".html_safe
  end
end
