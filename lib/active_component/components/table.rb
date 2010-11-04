class Table < ActiveComponent::Base

  attr_accessor :cols, :headers, :row_attrs, :header_attrs, :field_attrs
  
  def initialize(*args) 
    init_component(args, [:content, :title, :cols, :headers, :attributes, :row_attrs, :header_attrs, :field_attrs])

    # Defaults
    @title                    ||= content.first.class.to_s.hyphenize.pluralize
    if @cols.nil? && content.first.respond_to?(:attributes)
      @cols                     = content.first.attributes.keys
      @headers                ||= @cols.collect {|col| col.to_s.humanize}
    end
    @attributes[:class]       ||= @title
    @attributes[:cellspacing] ||= 0
    @row_attrs                ||= {}
    @header_attrs             ||= {}
    @field_attrs              ||= {}
  end
  
  def to_html
    print_tags do
      tag :table, @attributes do
        row_count = 0
        unless @headers.blank?
          tag :tr, get_row_attrs(row_count) do
            @headers.each_with_index do |header, i|
              tag :th, header, get_header_attrs(i)
            end
            row_count = 1
          end
        end
        content.each_with_index do |row, i|
          unless row.blank?
            tag :tr, get_row_attrs(row_count + i) do
              print_contents(:td, row, @cols, @field_attrs)
            end
          end
        end
      end
    end
  end
  
  private
  def get_attrs(attrs_collection, index = nil)
    attrs = attrs_collection[index] || attrs_collection
    attrs.is_a?(Hash) ? attrs : {}
  end
  
  def get_row_attrs(index = nil)
    get_attrs(@row_attrs, index)
  end
  
  def get_header_attrs(index = nil)
    get_attrs(@header_attrs, index)
  end
end