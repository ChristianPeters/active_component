describe Table do

  def things
    things = []
    things << Factory.build(:thing, :name => "thingamabob", :color => :yellow)
    things << Factory.build(:thing, :name => "whatchamacallit", :color => :red)
    things << Factory.build(:thing, :name => "gizmo", :color => :blue)
    things
  end

  context "rendering a matrix of primitive data" do
    it "should render without further input" do
      content = [["a", 1, "first entry"], ["b", 2, "second entry"]]
      table = Table.new content
      table.to_html.should == "<table cellspacing='0' class='arrays'>\n  <tr>\n    <td>a</td>\n    <td>1</td>\n    <td>first entry</td>\n  </tr>\n  <tr>\n    <td>b</td>\n    <td>2</td>\n    <td>second entry</td>\n  </tr>\n</table>\n"
    end

    it "should render correctly with all inputs set" do
      content = [["a", 1, "first entry"], ["b", 2, "second entry"]]
      table = Table.new content, 'examples', :cols => :to_s, :headers => ["char", "number", "entry"]
      table.to_html.should == "<table cellspacing='0' class='examples'>\n  <tr>\n    <th>char</th>\n    <th>number</th>\n    <th>entry</th>\n  </tr>\n  <tr>\n    <td>a</td>\n    <td>1</td>\n    <td>first entry</td>\n  </tr>\n  <tr>\n    <td>b</td>\n    <td>2</td>\n    <td>second entry</td>\n  </tr>\n</table>\n"
    end
  end

  context "rendering a collection of complex objects (e.g. instances of an Active Record model)" do
    it "should render without further input" do
      things = [Factory.build(:thing), Factory.build(:thing, :name => "Whatchamacallit", :color => :red)]
      table = Table.new things
      table.to_html.should == "<table cellspacing='0' class='things'>\n  <tr>\n    <th>Name</th>\n    <th>Color</th>\n  </tr>\n  <tr>\n    <td>Thingamabob</td>\n    <td>yellow</td>\n  </tr>\n  <tr>\n    <td>Whatchamacallit</td>\n    <td>red</td>\n  </tr>\n</table>\n"
    end

    it "should render complex ojects correctly with all inputs set" do
      color_temperature = proc {|thing| [:yellow, :orange, :red].include?(thing.color) ? "warm" : "cold"}
      table = Table.new things, 'things-table', :cols => [:name, color_temperature], :headers =>  ["Name", "Color Temperature"]
      table.to_html.should == "<table cellspacing='0' class='things-table'>\n  <tr>\n    <th>Name</th>\n    <th>Color Temperature</th>\n  </tr>\n  <tr>\n    <td>thingamabob</td>\n    <td>warm</td>\n  </tr>\n  <tr>\n    <td>whatchamacallit</td>\n    <td>warm</td>\n  </tr>\n  <tr>\n    <td>gizmo</td>\n    <td>cold</td>\n  </tr>\n</table>\n"
    end

    # According Haml template code
    #-----------------------------
    # %table
    #   %tr
    #     %th Name
    #     %th Reverse Name
    #     %th Color Temperature
    #   - @things.each |thing| do
    #     %tr
    #       %td= thing.name
    #       %td= thing.name.reverse
    #       %td.color-temp
    #         - temp = [:yellow, :orange, :red].include?(thing.color) ? "warm" : "cold"
    #         %span{:class => temp}
    #           = temp + "!"
    it "should render complex ojects using other components" do
      table = Table.new(things, 'things-table', :headers => ["Name", "Color Temperature"], :cols => [
        :name,
        proc {|thing| thing.name.reverse},
        proc do |thing|
          temp = [:yellow, :orange, :red].include?(thing.color) ? "warm" : "cold"
          Span.new(temp + "!", :class => temp)
        end
      ])
      table.to_html.should == "<table cellspacing='0' class='things-table'>\n  <tr>\n    <th>Name</th>\n    <th>Color Temperature</th>\n  </tr>\n  <tr>\n    <td>thingamabob</td>\n    <td>bobamagniht</td>\n    <td>\n      <span class='warm'>\n        warm!\n      </span>\n      \n    </td>\n  </tr>\n  <tr>\n    <td>whatchamacallit</td>\n    <td>tillacamahctahw</td>\n    <td>\n      <span class='warm'>\n        warm!\n      </span>\n      \n    </td>\n  </tr>\n  <tr>\n    <td>gizmo</td>\n    <td>omzig</td>\n    <td>\n      <span class='cold'>\n        cold!\n      </span>\n      \n    </td>\n  </tr>\n</table>\n"
    end
    #
    # it "should render using short hand helper functions"
    #   pending {}
    #   #tab = table(things, 'color-table', :cols => [ col(:name, 'Name'), col(nil, 'Reverse Name') {|thing| thing.name.reverse} ])
    #     #col(:title => 'Color Temperature', :class => 'color-temp') { |thing|
    #     #  temp = [:yellow, :orange, :red].include?(thing.color) ? "warm" : "cold"
    #     #  span(temp + "!", :class => temp)
    #     #}
    #   #tab.to_html.should == "not specified yet"
    # end
  end

  context "passing HTML attributes" do
    it "should forward attributes for headers" do
      table = Table.new things, :title => "my-things",
        :style => "padding: 10px", :class => "custom-class", :cellpadding => 0,
        :header_attrs => [{:class => 'name-header', :width => '200px'}, {:id => 'temp-col-header', :style => 'color: red'}]
      table.row_attrs = [{:class => 'head-row'}] + table.content.map {|thing| {:class => thing.name}}
      table.to_html.should == "<table cellpadding='0' cellspacing='0' class='my-things custom-class' style='padding: 10px'>\n  <tr class='head-row'>\n    <th class='name-header' width='200px'>Name</th>\n    <th id='temp-col-header' style='color: red'>Color</th>\n  </tr>\n  <tr class='thingamabob'>\n    <td>thingamabob</td>\n    <td>yellow</td>\n  </tr>\n  <tr class='whatchamacallit'>\n    <td>whatchamacallit</td>\n    <td>red</td>\n  </tr>\n  <tr class='gizmo'>\n    <td>gizmo</td>\n    <td>blue</td>\n  </tr>\n</table>\n"
    end
  end

end
