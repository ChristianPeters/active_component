class Section < ActiveComponent::Base
  
  attr_accessor :tag_type, :heading, :heading_level, :heading_attrs
  
  def initialize(*args, &content_block)
    init_component(args, [:content, :title, :tag_type, :heading, :heading_level, :heading_attrs, :attributes], &content_block)
    
    # Defaults
    @tag_type     ||= :section
    
    # Validations
    raise ArgumentError, "attributes must be a hash (given #{@attributes.inspect} in section #{@title})" unless @attributes.is_a? Hash
    # TODO: Heading rank
  end
  
  def to_html
    if @heading.present? && !@heading.is_a?(ActiveComponent)
      @heading = Heading.new @heading, @heading_level, @heading_attrs
      children.nil? ? (self << @heading) : self.prepend(@heading)
    end
    
    # TODO: Is this clean? Is there a better way than using concat?
    # wrap_contents(@tag_type, :attributes => @attributes, :content => [@heading, content]
    
    print_tags do
      tag :section, @attributes do
        concat print_object(@heading)
        content.transmogrify do |content|
          concat print_object(content)
        end
      end
    end
  end
  
end

# TODO: Sectioning Elements