describe ActiveComponent::Base do

  context "component initialization" do
    describe "html_class" do
      it "should include the hyphenized component title" do
        g = GreetingBox.new
        g.title = "Happy greeting box"
        g.instance_eval {[html_class].flatten}.should be_include 'happy-greeting-box'
        d = Div.new
        d.title = "Happy div"
        d.instance_eval {[html_class].flatten}.should be_include 'happy-div'
      end
      it "should include the class_name unless it is an html tag wrapper" do
        g = GreetingBox.new
        g.instance_eval {[html_class].flatten}.should be_include 'greeting-box'
        d = Div.new
        d.instance_eval {[html_class].flatten}.should_not be_include 'div'
      end
    end

    class NewsWidget < ActiveComponent::Base
      attr_accessor :author

      def initialize(*args, &content_block)
        init_component(args, [:content, :title, :author, :attributes], &content_block)
      end
    end

    describe "init_component" do
      context "custom component" do
        before :all do
          @news_content = "The pope claims that condoms are not necessarily evil. Where is this heading to?"
          # TODO support for special character removal pending
          #@news_title   = "Scandal in the Vatican!"
          @news_title   = "Scandal in the Vatican"
          @news_author  = "Karl Atzinger"
          @news_attributes = {:class => 'gossip', :title => 'click to read whole article'}
        end

        it "should set all parameters correctly when given in order" do
          n = NewsWidget.new @news_content, @news_title, @news_author, {:class => 'gossip'}
          n.content.should    == @news_content
          n.title.should      == @news_title
          n.author.should     == @news_author
          n.attributes.should == {:class => ['scandal-in-the-vatican', 'news-widget', 'gossip']}
        end

        it "should set all parameters correctly when given as key value pairs" do
          n = NewsWidget.new :attributes => @news_attributes, :title => @news_title, :content => @news_content, :author => @news_author
          n.content.should    == @news_content
          n.title.should      == @news_title
          n.author.should     == @news_author
          n.attributes.should == {:title => @news_attributes[:title], :class => ['scandal-in-the-vatican', 'news-widget', 'gossip']}
        end

        it "should set all parameters correctly when given in a mixed way" do
          n = NewsWidget.new @news_title, @news_author, :content => @news_content, :attributes => @news_attributes
          n.content.should    == @news_content
          n.title.should      == @news_title
          n.author.should     == @news_author
          n.attributes.should == {:title => @news_attributes[:title], :class => ['scandal-in-the-vatican', 'news-widget', 'gossip']}
        end

        it "should prioritize content blocks over content arguments" do
          n = NewsWidget.new(:content => "ignorable") { @news_content }
          n.content.should == @news_content
        end

        it "should fill @attributes with remaining arguments of the last hash" do
          n = NewsWidget.new @news_title, :id => 'news', :content => @news_content, :class => @news_attributes[:class]
          n.content.should    == @news_content
          n.title.should      == @news_title
          n.attributes.should == {:id => 'news', :class => ['scandal-in-the-vatican', 'news-widget', 'gossip']}
        end
      end

      context "html wrapper component (grand-child of base)" do
        before :all do
          @bq_content     = "It is better to be quotable than to be honest."
          @bq_title       = "Tom Stoppard on Quotations"
          @bq_attributes  = {:class => 'quotes', :cites => "http://www.quotationspage.com/quote/368.html"}
        end

        it "should set all parameters correctly when given in order" do
          bq = Blockquote.new @bq_content, @bq_title, @bq_author, @bq_attributes
          bq.content.should    == @bq_content
          bq.title.should      == @bq_title
          bq.attributes.should == {:cites => @bq_attributes[:cites], :class => [@bq_title.hyphenize, 'quotes']}
        end

        it "should set all parameters correctly when given as key value pairs" do
          bq = Blockquote.new :attributes => @bq_attributes, :title => @bq_title, :content => @bq_content
          bq.content.should    == @bq_content
          bq.title.should      == @bq_title
          bq.attributes.should == {:cites => @bq_attributes[:cites], :class => [@bq_title.hyphenize, 'quotes']}
        end

        it "should set all parameters correctly when given in a mixed way" do
          bq = Blockquote.new @bq_title, :content => @bq_content, :attributes => @bq_attributes
          bq.content.should    == @bq_content
          bq.title.should      == @bq_title
          bq.attributes.should == {:cites => @bq_attributes[:cites], :class => [@bq_title.hyphenize, 'quotes']}
        end

        it "should prioritize content blocks over content arguments" do
          bq = Blockquote.new(:content => "ignorable") { @bq_content }
          bq.content.should    == @bq_content
        end

        it "should fill attributes with remaining arguments of the last hash" do
          bq = Blockquote.new @bq_title, :cites => "http://www.quotationspage.com/quote/368.html", :content => @bq_content, :class => 'quotes'
          bq.content.should    == @bq_content
          bq.title.should      == @bq_title
          bq.attributes.should == {:cites => @bq_attributes[:cites], :class => [@bq_title.hyphenize, 'quotes']}
        end
      end

    end
  end

  context "tree node management" do
    it "should enable to add nodes as children" do
      a = Block.new
      b = Block.new("foo")
      c = Block.new("bar")
      a << b
      a << c
      a[b.object_id].should == b
      children = []
      a.children {|child| children << child.node_name}
      children.should == [b.object_id, c.object_id]
    end
  end

  context "instantiation helpers" do
    it "should be available after creating a component" do
      class NewGreetingBox < ActiveComponent::Base; end
      ActiveComponent.instance_methods.should be_include('new_greeting_box')
    end

    # TODO: How to test this?
    it "should be available to ActionView and render output"
    #   class GreetingBox < ActiveComponent::Base
    #     def initialize(*args, &content_block); init_component(args, [:content], &content_block); end
    #     def to_html; Span.new("Hello " + print_object(content), :class => 'greeting').to_html; end
    #   end
    #   ActiveComponent::TemplateHandler.new.instance_eval { compile(greeting_box("world")) }.should == "not specified yet"
    # end
  end

end

