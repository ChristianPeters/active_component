#TODO transmogrify on more than 2 levels

describe Object do
  
  context "transmogrify" do
    it "should yield self if its not enumerable" do
      block = Proc.new {|x| x.to_s.to_sym}
      obj = Object.new
      obj.transmogrify(&block).should eql(block.call(obj))
    end
  end
  context "transmogrify_with_index" do
    it "should not differ from transmogrify" do
      block = Proc.new {|x| x.to_s.to_sym}
      obj = Object.new
      obj.transmogrify_with_index(&block).should eql(obj.transmogrify(&block))
    end
  end
  
end

describe Enumerable do
  
  context "transmogrify" do
    before(:each) do
      @has_yielded = false
      @results = []
      @block = Proc.new do |x|
        @results << x.to_s.to_sym
        @has_yielded = true
      end
    end
    it "should yield each element" do  
      %w(a b c).transmogrify(&@block)
      @has_yielded.should be_true
      @results.should eql([:a, :b, :c])
    end
    after(:each) do
      @has_yielded, @results, @block = nil
    end
  end
  
  context "transmogrify_with_index" do
    before(:each) do
      @has_yielded = false
      @results = {}
      @block = Proc.new do |elem, index|
        @results[index] = elem.to_s.to_sym
      end
    end
    it "should yield each element with index" do
      %w(a b c).transmogrify_with_index(&@block)
      @results.should == { 0 => :a, 1 => :b, 2 => :c }
    end
    after(:each) do
      @result, @results, @block = nil
    end
  end
  
end