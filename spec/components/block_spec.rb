require "spec/active_component_spec_helper"
describe Block do
  include ActiveComponent
  include Haml::Helpers
  include ActiveSupport::CoreExtensions::String::Inflections
  
  before :each do
    @content     = "It is better to be quotable than to be honest."
    @title       = "Tom Stoppard on Quotations"
    @tag_type    = :blockquote
    @attributes  = {:class => 'quotes', :cites => "http://www.quotationspage.com/quote/368.html"}
  end

  describe "initialize" do
      
    it "should set all parameters correctly when given in order" do
      block = Block.new @content, @title, @tag_type, @attributes
      block.content.should            == @content
      block.title.should              == @title
      block.tag_type.should           == @tag_type
      block.attributes[:cites].should == @attributes[:cites]
    end
    
    it "should set all parameters correctly when given as key value pairs" do
      block = Block.new :attributes => @attributes, :title => @title, :content => @content, :tag_type => @tag_type
      block.content.should    == @content
      block.title.should      == @title
      block.tag_type.should   == @tag_type
      block.attributes.should == @attributes
    end
    
    it "should set all parameters correctly when given in a mixed way" do
      block = Block.new @title, @tag_type, :content => @content, :attributes => @attributes
      block.content.should    == @content
      block.title.should      == @title
      block.tag_type.should   == @tag_type
      block.attributes.should == @attributes
    end
    
    it "should assume :div as default block type" do
      block = Block.new { @content }
      block.tag_type.should == :div
    end
      
    it "should prioritize content blocks over arguments" do
      block = Block.new(:content => "ignorable") { @content }
      block.content.should == @content
    end
    
    it "should fill @attributes with remaining arguments of the last hash" do
      block = Block.new @title, :cites => "http://www.quotationspage.com/quote/368.html", :content => @content, :class => 'quotes'
      block.content.should    == @content
      block.title.should      == @title
      block.attributes.should == {:cites => @attributes[:cites], :class => [@title.hyphenize, 'block', @attributes[:class]]}
    end
    
    context "subclasses" do
      for elem in ActiveComponent::BLOCK_ELEMENTS
        elem_class = elem.to_s.camelize.constantize
        
        it "should set all parameters correctly when given in order" do
          block = elem_class.new @content, @title, @attributes
          block.content.should    == @content
          block.title.should      == @title
          block.tag_type.should   == elem
          block.attributes.should == {:cites => @attributes[:cites], :class => [@title.hyphenize, @attributes[:class]]}
        end
        
        it "should set all parameters correctly when given as key value pairs" do
          block = elem_class.new :attributes => @attributes, :title => @title, :content => @content
          block.content.should    == @content
          block.title.should      == @title
          block.tag_type.should   == elem
          block.attributes.should == {:cites => @attributes[:cites], :class => [@title.hyphenize, @attributes[:class]]}
        end
        
        it "should set all parameters correctly when given in a mixed way" do
          block = elem_class.new @title, :content => @content, :attributes => @attributes
          block.content.should    == @content
          block.title.should      == @title
          block.tag_type.should   == elem
          block.attributes.should == {:cites => @attributes[:cites], :class => [@title.hyphenize, @attributes[:class]]}
        end
        
        it "should prioritize content blocks over arguments" do
          block = elem_class.new(:content => "ignorable") { @content }
          block.content.should == @content
        end
        
        it "should not be possible to overwrite tag_type for subclasses of Block" do
          block = elem_class.new(:tag_type => :block) { @content }
          block.tag_type.should == elem
        end
        
        it "should fill @attributes with remaining arguments of the last hash" do
          block = elem_class.new @title, :cites => "http://www.quotationspage.com/quote/368.html", :content => @content, :class => 'quotes'
          block.content.should    == @content
          block.title.should      == @title
          block.attributes.should == {:cites => @attributes[:cites], :class => [@title.hyphenize, @attributes[:class]]}
        end
      end
    end
    
  end
  
  describe "to_html" do
    it "should render nested blocks" do       
      init_buffer
      block = Block.new @title, @tag_type, @attributes do
        [ 
          Block.new(@title, :tag_type => :h1),
          Block.new("It is better to be quotable than to be honest.", :tag_type => :p),
          Block.new("Details", :tag_type => :aside) do
            print_tags do
              tag :dl do
                tag :dt, "Author"
                tag :dd, "Tom Stoppard"
              end
            end
          end
        ]
      end
      block.to_html.should == "<#{@tag_type} cites='#{@attributes[:cites]}' class='#{@title.hyphenize} block #{@attributes[:class]}'>\n  <h1 class='block'>\n    #{@title}\n  </h1>\n  <p class='block'>\n    #{@content}\n  </p>\n  <aside class='details block'>\n    <dl>\n      <dt>Author</dt>\n      <dd>Tom Stoppard</dd>\n    </dl>\n    \n  </aside>\n  \n</#{@tag_type}>\n"
    end
  end
  
end

