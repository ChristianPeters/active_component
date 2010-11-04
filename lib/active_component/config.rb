module ActiveComponent
  # The module for all global ActiveComponent configurations
  module Config
    extend self

    @component_options = {}
    # The options hash for Haml when used within Rails.
    # See {file:HAML_REFERENCE.md#haml_options the Haml options documentation}.
    #
    # @return [{Symbol => Object}]
    attr_accessor :component_options
    
    def template_engine_options
      Haml::Template.options
    end  
    
    def template_engine_options=(options)
      Haml::Template.options = options
    end

    template_engine_options[:format]    ||= :html5
    
    if Haml::Util.rails_env == "development"
      component_options[:validate_html] ||= true
      template_engine_options[:ugly]    ||= false
    else
      component_options[:validate_html] ||= false
    end
    
  end
end