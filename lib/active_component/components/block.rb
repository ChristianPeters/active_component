class Block < ActiveComponent::Base
  
  attr_accessor :tag_type
  
  def initialize(*args, &content_block) 
    init_component(args, [:content, :title, :tag_type, :attributes], &content_block)
    
    # Defaults
    @tag_type ||= :div
  end
  
  def to_html
    wrap_contents(@tag_type, content, nil, @attributes)
  end
  
end

for elem in ActiveComponent::BLOCK_ELEMENTS
  sub_class = Object.const_set(elem.to_s.camelize, Class.new(Block))
  ActiveComponent::Base.def_component_helper(sub_class)
  
  sub_class.class_eval do
    
    def initialize(*args, &block)
      args.push({:tag_type => self.class.to_s.underscore.to_sym})
      super *args, &block
    end
    
  end
end