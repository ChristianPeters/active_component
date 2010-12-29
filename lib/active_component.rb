module ActiveComponent
  
  HTML5_ELEMENTS = {
    :meta             => [:base, :command, :link, :meta, :noscript, :script, :style, :title],
    :flow             => [:a, :abbr, :address, :article, :aside, :audio, :b, :bdo, :blockquote, :br, :button, :canvas, :cite, :code, :command, :datalist, :del, :details, :dfn, :div, :dl, :em, :embed, :fieldset, :figure, :footer, :form, :h1, :h2, :h3, :h4, :h5, :h6, :header, :hgroup, :hr, :i, :iframe, :img, :input, :ins, :kbd, :keygen, :label, :map, :mark, :math, :menu, :meter, :nav, :noscript, :object, :ol, :output, :p, :pre, :progress, :q, :ruby, :samp, :script, :section, :select, :small, :span, :strong, :sub, :sup, :svg, :table, :textarea, :time, :ul, :var, :video, :wbr],
    :sectioning       => [:article, :aside, :nav, :section],
    :heading          => [:h1, :h2, :h3, :h4, :h5, :h6, :hgroup],
    :phrasing         => [:abbr, :audio, :b, :bdo, :br, :button, :canvas, :cite, :code, :command, :datalist, :dfn, :em, :embed, :i, :iframe, :img, :input, :kbd, :keygen, :label, :mark, :math, :meter, :noscript, :object, :output, :progress, :q, :ruby, :samp, :script, :select, :small, :span, :strong, :sub, :sup, :svg, :textarea, :time, :var, :video, :wbr],
    :embedded         => [:audio, :canvas, :embed, :iframe, :img, :math, :object, :svg, :video],
    :interactive      => [:a, :button, :details, :embed, :iframe, :keygen, :label, :select, :textarea],
    :sectioning_roots => [:blockquote, :body, :details, :fieldset, :figure, :td],
    :form_associated  => [:button, :fieldset, :input, :keygen, :label, :meter, :object, :output, :progress, :select, :textarea],
    :block_candidates => [:section, :nav, :article, :aside, :h1, :h2, :h3, :h4, :h5, :h6, :hgroup, :header, :footer, :address, :p, :pre, :blockquote, :div],
    :uncategorized    => [:col, :colgroup, :dd, :dt, :figcaption, :head, :html, :legend, :li, :optgroup, :option, :param, :rp, :rt, :source, :summary, :tbody, :tfoot, :th, :thead, :tr]
  }
  
  EMPTY_ELEMENTS      = [:area, :base, :br, :col, :command, :embed, :hr, :img, :input, :keygen, :link, :meta, :param, :source, :wbr]
  PHRASING_ELEMENTS   = HTML5_ELEMENTS[:phrasing] - HTML5_ELEMENTS[:interactive] - HTML5_ELEMENTS[:embedded] - EMPTY_ELEMENTS - [:noscript, :time] + [:ins, :del]
  BLOCK_ELEMENTS      = HTML5_ELEMENTS[:block_candidates] - HTML5_ELEMENTS[:sectioning] - HTML5_ELEMENTS[:sectioning_roots] - HTML5_ELEMENTS[:heading] - [:p, :pre] + [:head, :html, :hgroup]
  SECTION_ELEMENTS    = HTML5_ELEMENTS[:sectioning] + HTML5_ELEMENTS[:sectioning_roots] - HTML5_ELEMENTS[:form_associated]
  HEADING_ELEMENTS    = HTML5_ELEMENTS[:heading] - [:hgroup]
  
  # Embed
  # Table
  # List
  # p, pre
  # figure
  # title
  
  class ActiveComponentError < StandardError; end
  class InvalidHtmlError < ActiveComponentError; end
    
  # Generates a collection of tags wrapping content that is optionally printed using method(s)
  def print_contents(tag, content_or_contents, method_or_methods = nil, *flags_and_attributes)
    flags       = []
    attributes  = {}
    # Collect all flags (non-Hash) and attributes (by merging all Hashs)
    for arg in flags_and_attributes
      arg.is_a?(Hash) ? attributes.merge!(arg) : flags << arg
    end
  
    # Create a callable printing procedure for the case 
    # that its whole output should be wrapped with a tag 
    printing_procedure = Proc.new do
      unless method_or_methods.present?
        # Print content(s) without using methods
        content_or_contents.transmogrify do |content|
          if flags.include? :wrap_whole_content
            # Write printed object to buffer (without tag)
            concat print_object(content)
          else
            # Wrap printed object with a tag and write result to buffer
            tag(tag, print_object(content), attributes)
          end
        end
      else
        unless flags.include? :couple_methods_with_contents
          # Print content(s) using (fixed set of) method(s)
          content_or_contents.transmogrify do |content|
            method_or_methods.transmogrify do |method|
              if flags.include? :wrap_whole_content
                # Write printed object to buffer (without tag)
                concat print_object(content, method)
              else
                # Wrap printed object with a tag and write result to buffer
                tag(tag, print_object(content, method), attributes)
              end
            end
          end
        else
          # Print contents using individually paired methods
          content_or_contents.transmogrify_with_index do |content, index|
            method = method_or_methods[index]
            if flags.include? :wrap_whole_content
              # Write printed object to buffer (without tag)
              concat print_object(content, method)
            else
              # Wrap printed objects with a tag and write result to buffer
              tag(tag, print_object(content, method), attributes)
            end
          end
        end
      end
    end
    
    if flags.include? :wrap_whole_content
      # Wrap output of printing procedure with tag and write result to buffer
      tag(tag, attributes, &printing_procedure)
    else
      # Call printing procedure and write result to buffer
      printing_procedure.call
    end
    
    # Return buffer content
    buffer
  end 
  
  # Wraps content(s) into a single tag, optionally using a method
  def wrap_contents(tag, content_or_contents, method_or_methods = nil, *flags_and_attributes)
    print_contents(tag, content_or_contents, method_or_methods, :wrap_whole_content, *flags_and_attributes)
  end
  
  # Wraps haml_tag and directly captures the output buffer product.
  # This should only be used if a single +haml_tag+ should be captured.
  # Note that capturing buffer content should be done as rare as possible for performance reasons.
  # For non-trivial content you might want to use `print_tags { tag(:ul) { tag(:li, content) } }` instead.
  #
  # @param name [#to_s] The name of the tag
  # @param flags [Array<Symbol>] Haml end-of-tag flags
  # @param attributes [Hash] Hash of Haml (HTML) attributes
  #
  # @overload print_tag(name, *flags, attributes = {})
  # @overload print_tag(name, text, *flags, attributes = {})
  #   @param text [#to_s] The text within the tag
  def print_tag(name, *rest)
    puts "warning: print_tag does not except blocks. Use print_tags { tag(:ul) { tag(:li, content) } } instead" if block_given?
    print_buffer { tag(name, *rest) }
  end
  
  # Prints a single object, optionally using a method
  def print_object(object, method = nil)
    #logger = RAILS_DEFAULT_LOGGER
    #logger.info "\"print_object speaking. I am about to print Object: " + object.inspect + " Method: " + method.inspect + ". Over.\""
    unless method.present?
      if object.respond_to? :to_html
        object.to_html
      elsif object.respond_to? :call
        begin
          object.call.to_s
        # Haml buffers may be provided in callable form, but have to be captured
        rescue Haml::Error
          # Rescue is only successful if buffer available in current scope
          print_buffer { object.call }
        end
      else
        object.to_s   # Each object responds to :to_s
      end
    else
      # If the given method can be invoked on the object, the result is returned
      if method.respond_to?(:to_sym) && object.respond_to?(method)
        object.send(method.to_sym).to_s
      # If the given method can be alled with the object, the result is returned
      elsif method.respond_to? :call
        # Call method with object if it takes at most 1 required parameter
        # Arity returns -n-1 if n > 0 optional parameters exist
        if method.arity == 1 || method.arity == -1 || method.arity == -2
          method.call(object).to_s
        else
          raise ArgumentError, "Content is not printable. Too many (or no) parameters expected in the following method: " + method.inspect
        end
      else
        raise ArgumentError, "Content is not printable. Provide a Proc/Method that can be called with object or a method name that can be invoked on the object. Alternatively, do not provide a method argument so that the object's :to_html, :call, or :to_s method is called. Parameters given: Object: " + object.inspect + " Method: " + method.inspect
      end 
    end
  end

end

$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

require 'active_component/core_extensions'
require 'active_component/config'
require 'active_component/base'

# Load components
require 'active_component/components/block'
require 'active_component/components/empty_tag'
require 'active_component/components/heading'
require 'active_component/components/inline_tag'
require 'active_component/components/section'
require 'active_component/components/table'
