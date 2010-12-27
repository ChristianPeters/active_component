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
  
  def_html_sub_components ActiveComponent::PHRASING_ELEMENTS, self
end
