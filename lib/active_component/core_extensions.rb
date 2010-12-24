class Object
  
  # Transmogrify yields self to the given block by default
  def transmogrify(*ignored_args)
    yield self
  end
  
  # Wrapper for enumerable transmogrify
  def transmogrify_with_index(&block)
    transmogrify(:yield_index, &block)
  end
  
  alias :includes_a? :is_a?
  
end

class String
  
  # Performs same transformation as underscore, but with hyphens
  def hyphenize
    gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("_", "-").
    tr(" ", "-").
    downcase
  end
  
end

class Symbol
  
  def to_class_constant
    to_s.camelize.constantize
  end
  
end

module Enumerable
  
  # Transmogrify yields each element to the given block
  def transmogrify(*options)    
    if options.include? :yield_index
      each_with_index do |element, index|
        yield element, index
      end
    else
      each do |element| 
        yield element
      end
    end
  end
  
  # Determines if enumerable contains an object of the specified class
  def includes_a?(klass)
    each do |e|
      return true if e.is_a? klass      
    end
    false
  end
  
  # Returns the first object of the specified class contained in enumerable
  def find_a(klass)
    each do |e|
      return e if e.is_a? klass
    end
    nil
  end
  
end

require 'action_view'
# FIXME: There should be a better way to provide the module to ActionView.
class ActionView::Base
  include ActiveComponent
end

module ActiveSupport::CoreExtensions::Hash::ReverseMerge
  alias :set_defaults :reverse_merge 
  alias :set_defaults! :reverse_merge! 
end

module Haml::Helpers
  alias :print_tags :capture_haml
  alias :capture :capture_haml
  alias :tag :haml_tag
  alias :init_buffer :init_haml_helpers
  alias :concat :haml_concat
  alias :string :haml_concat
end
