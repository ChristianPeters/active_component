describe ActiveComponent::Base do
  
  context "component initialization" do
    describe "html_class" do
      it "should include the hyphenized component title" do
        g = GreetingBox.new
        g.title = "Happy greeting box"
        g.instance_eval {[html_class].flatten}.should be_include 'happy-greeting-box'
        d = Div.new
        d.title = "Happy div"
        g.instance_eval {[html_class].flatten}.should be_include 'happy-div'
      end
      it "should include the class_name unless it is an html tag wrapper", :focus => true do
        g = GreetingBox.new
        g.instance_eval {[html_class].flatten}.should be_include 'greeting-box'
        d = Div.new
        d.instance_eval {[html_class].flatten}.should_not be_include 'div'
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
