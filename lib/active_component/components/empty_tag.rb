# encoding: utf-8

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

  def_html_sub_components ActiveComponent::EMPTY_ELEMENTS, self
end
