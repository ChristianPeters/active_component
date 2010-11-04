module ActiveComponent
  class TemplateHandler
    include ActionView::TemplateHandlers::Compilable
    
    def compile(template)
      # For Rails < 2.1.0, template is a string
      # For Rails >= 2.1.0, template is a Template object
      if template.respond_to? :source
        # # For Rails >=3.0.0, there is a generic identifier
        # options[:filename] = template.respond_to?(:identifier) ? template.identifier : template.filename
        template.source
      else
        template
      end
    end
    
  end
end