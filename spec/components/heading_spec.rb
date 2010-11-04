require "spec/active_component_spec_helper"
describe Heading do
  include ActiveComponent
  include Haml::Helpers
  include ActiveSupport::CoreExtensions::String::Inflections
  
  before :all do
    @content     = "Wall Street Retreats in the Face of a Slowdown"
    @title       = "Business News"
    @level       = 3
    @attributes  = {:class => 'news business'}
  end

      
  # describe "initialize" do
  #     
  #   it "should set all parameters correctly when given in order" do
  #     heading = Heading.new @content, @title, @level, @attributes
  #     heading.content.should    == @content
  #     heading.title.should      == @title
  #     heading.level.should      == @level
  #     heading.attributes.should == @attributes
  #   end
  #   
  #   it "should set all parameters correctly when given as key value pairs" do
  #     heading = Heading.new :attributes => @attributes, :title => @title, :content => @content, :level => @level
  #     heading.content.should    == @content
  #     heading.title.should      == @title
  #     heading.level.should      == @level
  #     heading.attributes.should == @attributes
  #   end
  #   
  #   it "should set all parameters correctly when given in a mixed way" do
  #     heading = Heading.new @title, @level, :content => @content, :attributes => @attributes
  #     heading.content.should    == @content
  #     heading.title.should      == @title
  #     heading.level.should      == @level
  #     heading.attributes.should == @attributes
  #   end
  #     
  #   it "should prioritize content headings over arguments" do
  #     heading = Heading.new(:content => "ignorable") { @content }
  #     heading.content.call.should == @content
  #   end
  #   
  #   it "should fill @attributes with remaining arguments of the last hash" do
  #     heading = Heading.new @title, :content => @content, :class => 'news business'
  #     heading.content.should    == @content
  #     heading.title.should      == @title
  #     heading.attributes.should == @attributes
  #   end
  #   
  # end
  
  describe "siblings_level" do
    
    it "should adopt correct siblings level" do
      h1 = Heading.new('header 1', :level => 3)
      h2 = Heading.new
      h3 = Heading.new [h1, h2]
      h2.siblings_level.should == 3
    end
    
    it "should return nil if no heading sibling exists" do
      h1 = Heading.new
      h2 = Heading.new h1
      h1.siblings_level.should be_nil
    end
        
    it "should return nil if existing heading sibling has no rank" do
      h1 = Heading.new('header 1')
      h2 = Heading.new
      h3 = Heading.new [h1, h2]
      h2.siblings_level.should be_nil
    end
    
  end
  
  describe "determine_level" do
    
    it "should return the rank of a given sibling Heading" do
      h1 = Heading.new(:level => 3)
      h2 = Heading.new
      h3 = Heading.new([h1, h2])
      
      h2.determine_level.should == 3
    end
    
    it "should determine heading rank correctly based on the hierarchy" do
      h1 = Heading.new('header 1')
      h2 = Heading.new('header 2')
      h3 = Heading.new('header 3')
      div2 = Div.new(:content => [h2, h3])
      div = Div.new(:content => [
        h1, 
        div2
      ])
      h2.determine_level.should == 2
    end
    
  end
  
  
  describe "to_html" do
    
    it "should compute heading levels automatically based on the node hierarchy" do
      section = Section.new(:heading => @title, :content => [
        Heading.new("It's better to be honest!"),
        Section.new(:heading => "Tom Stoppard", :content => [
          Div.new(:title => "Some div inbetween", :content => [
            Heading.new("Yet Another Heading"),
            Section.new("Details", :heading => "Leaf Heading")
          ])
        ])
      ])
      section.to_html.should == "<section>\n  <h1 class='heading'>\n    Business News\n  </h1>\n  \n  <h1 class='heading'>\n    It's better to be honest!\n  </h1>\n  \n  <section>\n    <h2 class='heading'>\n      Tom Stoppard\n    </h2>\n    \n    <div class='some-div-inbetween'>\n      <h3 class='heading'>\n        Yet Another Heading\n      </h3>\n      \n      <section>\n        <h4 class='heading'>\n          Leaf Heading\n        </h4>\n        \n        Details\n      </section>\n      \n    </div>\n    \n  </section>\n  \n</section>\n"
    end
  
    it "should compute heading levels automatically also when block syntax used" do
      section = Section.new(:heading => @title, :content => [
        Heading.new("It's better to be honest!"),
        Section.new(:heading => "Tom Stoppard", :content => [
          Div.new(:title => "Some div inbetween") do 
            [
              Heading.new("Yet Another Heading"),
              Section.new("Details", :heading => "Leaf Heading")
            ]
          end
        ])
      ])
      section.to_html.should == "<section>\n  <h1 class='heading'>\n    Business News\n  </h1>\n  \n  <h1 class='heading'>\n    It's better to be honest!\n  </h1>\n  \n  <section>\n    <h2 class='heading'>\n      Tom Stoppard\n    </h2>\n    \n    <div class='some-div-inbetween'>\n      <h3 class='heading'>\n        Yet Another Heading\n      </h3>\n      \n      <section>\n        <h4 class='heading'>\n          Leaf Heading\n        </h4>\n        \n        Details\n      </section>\n      \n    </div>\n    \n  </section>\n  \n</section>\n"
    end
    
  end
  
end