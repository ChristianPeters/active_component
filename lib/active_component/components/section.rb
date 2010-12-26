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
      tag @tag_type, @attributes do
        concat print_object(@heading)
        content.transmogrify do |content|
          concat print_object(content)
        end
      end
    end
  end

end

for elem in ActiveComponent::SECTION_ELEMENTS
  sub_class = Object.const_set(elem.to_s.camelize, Class.new(Section))
  ActiveComponent::Base.def_component_helper(sub_class)

  sub_class.class_eval do

    def initialize(*args, &block)
      args << {:tag_type => self.class.to_s.underscore.to_sym}
      super *args, &block
    end

  end
end
