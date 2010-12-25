class InlineTag < ActiveComponent::Base
  
  attr_accessor :tag_type
  
  # Content can be passed as a block
  def initialize(*args, &content_block) 
    init_component(args, [:content, :title, :tag_type, :attributes], &content_block)
    
    # Defaults
    @tag_type     ||= :span
  end
  
  def to_html
    if ActiveComponent::Config.component_options[:validate_html]
      raise InvalidHtmlError, "Inline tags must not have blocks as inner content." if content.includes_a? Block
    end

    wrap_contents(@tag_type, content, nil, @attributes)
  end
  
end

for elem in ActiveComponent::PHRASING_ELEMENTS
  sub_class = Object.const_set(elem.to_s.camelize, Class.new(InlineTag))
  ActiveComponent::Base.def_component_helper(sub_class)
  
  sub_class.class_eval do
    
    def initialize(*args, &block)
      args << {:tag_type => self.class.to_s.underscore.to_sym}
      super *args, &block
    end
    
  end
end
