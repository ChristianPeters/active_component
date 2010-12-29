describe Block do
  include ActiveComponent
  include Haml::Helpers

  before :each do
    @content     = "It is better to be quotable than to be honest."
    @title       = "Tom Stoppard on Quotations"
    @tag_type    = :blockquote
    @attributes  = {:class => 'quotes', :cites => "http://www.quotationspage.com/quote/368.html"}
  end

  describe "initialize" do
    it "should assume :div as default block type" do
      block = Block.new { @content }
      block.tag_type.should == :div
    end

    it "should not be possible to overwrite tag_type for subclasses of Block" do
      for elem in ActiveComponent::BLOCK_ELEMENTS
        elem_class = elem.to_s.camelize.constantize
        block = elem_class.new(:tag_type => :block) { @content }
        block.tag_type.should == elem
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
            print_buffer do
              tag_to_buffer :dl do
                tag_to_buffer :dt, "Author"
                tag_to_buffer :dd, "Tom Stoppard"
              end
            end
          end
        ]
      end
      block.to_html.should == "<#{@tag_type} cites='#{@attributes[:cites]}' class='#{@title.hyphenize} block #{@attributes[:class]}'>\n  <h1 class='block'>\n    #{@title}\n  </h1>\n  <p class='block'>\n    #{@content}\n  </p>\n  <aside class='details block'>\n    <dl>\n      <dt>Author</dt>\n      <dd>Tom Stoppard</dd>\n    </dl>\n    \n  </aside>\n  \n</#{@tag_type}>\n"
    end
  end

end

