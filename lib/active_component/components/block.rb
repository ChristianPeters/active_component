# encoding: utf-8

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

  def_html_sub_components ActiveComponent::BLOCK_ELEMENTS, self
end

