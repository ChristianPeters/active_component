# encoding: utf-8

require 'active_component_spec_helper'

describe ActiveComponent do

  before(:each) { @comp = Block.new }
  after(:each) { @comp = nil }

  describe "print_contents" do
    it "should print content and wrap it with a tag" do
      content = "content"
      @comp.print_contents(:span, content).should == "<span>content</span>\n"
    end

    it "should print multiple contents and wrap each item with a tag" do
      content = [:a, "b", 3]
      Factory.sequence(:content) {|n| content[n]}
      @comp.print_contents(:span, content).should == "<span>a</span>\n<span>b</span>\n<span>3</span>\n"
    end

    it "should print content using a method and wrap the output with a tag" do
      deep_thought = mock :content
      deep_thought.should_receive(:question).once.and_return(42)
      @comp.print_contents("div.the-answer", deep_thought, :question).should == "<div class='the-answer'>42</div>\n"
    end

    it "should print multiple contents using a method and wrap each one with a tag" do
      names = %w(Aron Noel Trebor)
      transformation = Proc.new {|x| x.downcase.reverse.humanize}
      @comp.print_contents(:li, names, transformation).should == "<li>Nora</li>\n<li>Leon</li>\n<li>Robert</li>\n"
    end

    it "should print multiple contents using a set of methods and wrap each of the method outputs with a tag" do
      things = []
      things << Factory.build(:thing, :name => "thingamabob", :color => :yellow)
      things << Factory.build(:thing, :name => "whatchamacallit", :color => :red)
      things << Factory.build(:thing, :name => "gizmo", :color => :blue)
      @comp.print_contents(:p, things, things.first.attributes.keys).should == "<p>thingamabob</p>\n<p>yellow</p>\n<p>whatchamacallit</p>\n<p>red</p>\n<p>gizmo</p>\n<p>blue</p>\n"
    end

    it "should print multiple contents, each item being paired with its own method and wrap each of the method outputs with a tag" do
      accomodations = []
      accomodations << mock(:hostel)
      accomodations << mock(:campground)
      accomodations[0].should_receive(:rooms).and_return(15)
      accomodations[1].should_receive(:campsites).and_return(25)
      capacity_information = [
        Proc.new {|h| "There are #{h.rooms} hostel rooms available."},
        Proc.new {|c| "The campground can take #{c.campsites} tents."}
      ]
      @comp.print_contents(:p, accomodations, capacity_information, :couple_methods_with_contents).should == "<p>There are 15 hostel rooms available.</p>\n<p>The campground can take 25 tents.</p>\n"
    end

    it "should merge attributes"

  end

  describe "wrap_contents" do
    it "should wrap text content with a tag" do
      content = "content"
      @comp.print_contents(:span, content, nil, :wrap_whole_content).should == "<span>\n  content\n</span>\n"
    end

    it "should wrap HTML content with a tag" do
      content = "<span>\n  content\n</span>\n"
      @comp.wrap_contents(:p, content).should == "<p>\n  <span>\n    content\n  </span>\n</p>\n"
    end

    it "should wrap multiple contents with a tag" do
      names_list = ["<li>Nora</li>", "<li>Leon</li>", "<li>Robert</li>"]
      @comp.wrap_contents(:ul, names_list).should == "<ul>\n  <li>Nora</li>\n  <li>Leon</li>\n  <li>Robert</li>\n</ul>\n"
    end

    it "should print content using a method and wrap the output with a tag" do
      deep_thought = mock :content
      deep_thought.should_receive(:question).once.and_return(42)
      @comp.wrap_contents("div.the-answer", deep_thought, :question).should == "<div class='the-answer'>\n  42\n</div>\n"
    end

    it "should print multiple contents using a method and wrap the whole output into a tag" do
      names = %w(Aron Noel Trebor)
      transformation = Proc.new {|x| x.downcase.reverse.humanize}
      @comp.wrap_contents(:p, names, transformation).should == "<p>\n  Nora\n  Leon\n  Robert\n</p>\n"
    end

    it "should wrap multiple contents with a tag, each item being printed using its own method" do
      accomodations = []
      accomodations << mock(:hostel)
      accomodations << mock(:campground)
      accomodations[0].should_receive(:rooms).and_return(15)
      accomodations[1].should_receive(:campsites).and_return(25)
      capacity_information = [
        Proc.new {|h| "There are #{h.rooms} hostel rooms available."},
        Proc.new {|c| "The campground can take #{c.campsites} tents."}
      ]
      @comp.wrap_contents(:p, accomodations, capacity_information, :couple_methods_with_contents).should == "<p>\n  There are 15 hostel rooms available.\n  The campground can take 25 tents.\n</p>\n"
    end
  end

  describe "print_object" do
    it "should print primitive data" do
      for primitive in ["test", 1.0, 7, true, '']
        @comp.print_object(primitive).should == primitive.to_s
      end
    end

    it "should call callable objects" do
      callable = mock :method
      callable.should_receive(:call).at_least(:once).and_return(42)
      @comp.print_object(callable).should == callable.call.to_s
    end

    it "should render components" do
      renderable = mock :component
      html = "<div>\n Component content\n</div"
      renderable.should_receive(:to_html).at_least(:once).and_return(html)
      @comp.print_object(renderable).should == html
    end

    it "should capture Haml buffers" do
      p = lambda { @comp.haml_tag(:span, "haml") }
      @comp.print_object(p).should == "<span>haml</span>\n"
      p = lambda { @comp.haml_concat("written-to-buffer-and-captured") }
      @comp.print_object(p).should == "written-to-buffer-and-captured\n"
    end

    it "should utilize receiver capabilities of object if applicable" do
      receiver = mock :object
      receiver.should_receive(:message).at_least(:once).and_return(42)
      @comp.print_object(receiver, :message).should == receiver.message.to_s
    end

    it "should yield non-receiver objects if a suitable method is given" do
      callable = mock :method
      object = 42
      callable.should_receive(:arity).at_least(:once).and_return(1, -1, -2)
      callable.should_receive(:call).with(object).at_least(:once).and_return(42)
      3.times do
        @comp.print_object(object, callable).should == callable.call(object).to_s
      end
    end

    it "should not try to print non-receiver objects if an unsuitable method is given" do
      callable = mock :method
      object = 42
      callable.should_receive(:arity).at_least(:once).and_return(0, 2, -3)
      callable.should_not_receive(:call)
      3.times do
        lambda {@comp.print_object(object, callable)}.should raise_error(ArgumentError)
      end
    end
  end

end
