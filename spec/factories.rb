class Thing
  attr_accessor :name, :color
  
  def attributes
    attr = ActiveSupport::OrderedHash.new
    attr[:name] = name
    attr[:color] = color
    attr
  end
end

Factory.define :thing do |t|
  t.name        "Thingamabob"
  t.color       :yellow
end

Factory.define :component_base, :class => ActiveComponent::Base do; end

class GreetingBox < ActiveComponent::Base
  attr_accessor :content, :title, :attributes
end
