describe Section do
  
  before :each do
    @content     = "It is better to be quotable than to be honest."
    @title       = "Tom Stoppard on Quotations"
    @tag_type    = :blockquote
    @attributes  = {:class => 'quotes', :cites => "http://www.quotationspage.com/quote/368.html"}
  end

  describe "initialize" do
    it "should assume :section as default section type" do
      section = Section.new @content
      section.tag_type.should == :section
    end

    it "should not be possible to overwrite tag_type for subclasses of section" do
      for elem in ActiveComponent::SECTION_ELEMENTS
        elem_class = elem.to_s.camelize.constantize
        section = elem_class.new(:tag_type => :section) { @content }
        section.tag_type.should == elem
      end
    end
  end

  describe "to_html" do
    it "should be able to render nested sections"

    it "should be able to render section subclasses", :focus => true do
      b = Blockquote.new(@content, @title, @attributes)
      b.to_html.should == "<blockquote cites='http://www.quotationspage.com/quote/368.html' class='tom-stoppard-on-quotations quotes'>\n  It is better to be quotable than to be honest.\n</blockquote>"
    end
  end
end
