require 'lib/active_component.rb'

require 'lib/active_component/template_handler.rb'
extend ActionView::TemplateHandlers
register_template_handler :act, ActiveComponent::TemplateHandler