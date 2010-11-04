class Heading < ActiveComponent::Base

  attr_reader :level
   
  def level=(level)
    unless level.nil?
      raise ArgumentError, "heading_level must be numeric (given #{level.inspect} in heading #{@content})" unless level.is_a? Numeric
      puts "warning: heading_level should be an integer and between 1 and 6 (given #{level} in heading #{@content})" unless level.between?(1,6)
      @level = [[level.to_i, 6].min, 1].max
    end
  end
  
  def initialize(*args, &content_block)
    init_component(args, [:content, :title, :level, :attributes], &content_block)
  end
  
  def to_html
    @level ||= determine_level

    wrap_contents("h" + @level.to_s, content, nil, @attributes)
  end
  
  # Determines the heading level by adopting the siblings' one
  # or by determining the parent's one recursively
  def determine_level
    return 1     if is_root?
    return level if level.present?
    
    siblings_level or (
      if Heading.has_parent_heading?(self)
        Heading.parent_heading(self).determine_level + 1
      else
        1
      end
    )
  end
  
  # Collects the level of sibling headings
  def siblings_level
    siblings.collect {|sib| sib.level if sib.is_a?(Heading)}.compact.min
  end
  
  # Retrieves the next Heading of the node hierarchy above a given node
  def Heading.parent_heading(node)
    raise ArgumentException, "Node has no heading parent." unless Heading.has_parent_heading?(node)
    node.parent.siblings.find_a(Heading) or Heading.parent_heading(node.parent)
  end
  
  # Checks whether a Heading exists in the node hierarchy above a given node
  def Heading.has_parent_heading?(node)
    !node.is_root? && (
      node.parent.siblings.includes_a?(Heading) || 
      Heading.has_parent_heading?(node.parent)
    )
  end
  
end


for elem in ActiveComponent::HEADING_ELEMENTS
  # Creating an anonymous Heading subclass and set according constant
  sub_class = Object.const_set(elem.to_s.camelize, Class.new(Heading))
  # Register component instantiation helper manually with the class constant
  ActiveComponent::Base.def_component_helper(sub_class)
  
  sub_class.class_eval do
    
    def initialize(*args, &block)
      args.push({:level => self.class.to_s.last.to_i})
      super *args, &block
    end
    
  end
end