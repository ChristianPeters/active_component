class EmptyTag < ActiveComponent::Base
  
  attr_accessor :tag_type
  
  # Content can be passed as a block
  def initialize(*args) 
    init_component(args, [:title, :tag_type, :attributes])
    
    # Defaults
    @tag_type     ||= :br
  end
  
  def to_html
    if ActiveComponent::Config.component_options[:validate_html]
      raise InvalidHtmlError, "Empty HTML elements must not have content." if content.present?
    end
    
    name, attrs = merge_name_and_attributes(@tag_type.to_s, @attributes)
    attrs = Haml::Precompiler.build_attributes(@haml_buffer.html?, @haml_buffer.options[:attr_wrapper], attrs)
    "<#{name}#{attrs} />"
  end
  
end

for elem in ActiveComponent::EMPTY_ELEMENTS
  sub_class = Object.const_set(elem.to_s.camelize, Class.new(EmptyTag))
  ActiveComponent::Base.def_component_helper(sub_class)
  
  sub_class.class_eval do
    
    def initialize(*args)
      args << {:tag_type => self.class.to_s.underscore.to_sym}
      super *args
    end
    
  end
end
