# TODO: Make these platform independent (they're UNIX only right now)

require File.dirname(__FILE__) + '/spec_helper.rb'
require File.dirname(__FILE__) + '/../lib/dcov.rb'

describe "The Dcov analyzer" do
  before(:each) do
    @myopts = OptionsMock.new
  end
  
  before(:all) do
    @myopts = OptionsMock.new
    
    @analyzer = Dcov::Analyzer.new(@myopts)
  end
  
  it "should be of class Dcov::Coverage." do
    @analyzer.class.should == Dcov::Analyzer
  end
  
  it "should have the given hierarchy in an attribute." do
    puts @analyzer.hierarchy
  end
  
  it "should give correct coverage information on classes." do
    @analyzer.stats.coverage_rating(:class).should == 20
  end
  
  it "should give correct coverage information on modules." do
    @analyzer.stats.coverage_rating(:module).should == 33
  end
  
  it "should give correct coverage information on methods." do
    @analyzer.stats.coverage_rating(:method).should == 50
  end
  
  it "should properly process a class." do
    @myopts[:files] = 'spec/just_a_class.rb'
    coverage_is_zero = Dcov::Analyzer.new(@myopts)
    
    coverage_is_zero.stats.coverage_rating(:class).should == 50
  end
  
  it "should properly process a module." do
    @myopts[:files] = 'spec/just_a_module.rb'
    coverage_is_zero = Dcov::Analyzer.new(@myopts)
    
    coverage_is_zero.stats.coverage_rating(:module).should == 50
  end
  
  it "should properly process a method." do
    @myopts[:files] = 'spec/just_a_method.rb'
    coverage_is_zero = Dcov::Analyzer.new(@myopts)
    
    coverage_is_zero.stats.coverage_rating(:method).should == 50
  end
  
  it "should generate HTML." do
    File.exists?('coverage.html').should == true
  end
  
  it "should go through the whole process without breaking!" do
    lambda { Dcov::Analyzer.new(@myopts) }.should_not raise_error(Exception)
  end
  
  it "should give an exception if no files are given." do
    @myopts[:files] = []
    lambda { Dcov::Analyzer.new(@myopts) }.should raise_error(RuntimeError)
    
    @myopts[:files] = nil
    lambda { Dcov::Analyzer.new(@myopts) }.should raise_error(RuntimeError)
  end
  
  it "should raise an exception if told to process the wrong object." do
    # TODO: make a mock object
  end
  
  it "should raise a (sane, readable) exception if the HTML file isn't writable." do
    `touch coverage.html; chmod 000 coverage.html`
    lambda { Dcov::Analyzer.new(@myopts) }.should raise_error(RuntimeError)
    `chmod 744 coverage.html`
  end
  
  it "should still analyze if the structure is invalid." do
    # TODO: Make a mock structure
  end
  
  it "should return zero for coverage if the structure is empty." do
    @myopts[:files] = 'spec/blank_code.rb'
    coverage_is_zero = Dcov::Analyzer.new(@myopts)
    
    coverage_is_zero.stats.coverage_rating(:class).should == 0
    coverage_is_zero.stats.coverage_rating(:module).should == 0
    coverage_is_zero.stats.coverage_rating(:method).should == 0
  end
  
  it "should process the tokens into a proper structure after quality analysis." do
    @analyzer.stats.renderable_data[:structured].should_not == nil
  end
  
  it "should attach reporting data to each token." do
    @analyzer.stats.renderable_data[:structured][@analyzer.stats.renderable_data[:structured].keys[0]][0].reporting_data.should == {}
  end
  
  it "should attach extra reporting data to each method." do
    @analyzer.stats.renderable_data[:structured]['Document::Element'][1][0].reporting_data.should_not == {}
  end
  
  it "should catch tokens without examples." do
    @analyzer.stats.renderable_data[:structured]['Document::Element'][1][2].reporting_data.keys.include?(:no_examples).should == true
  end
  
  it "should catch methods that have undocumented default values." do
    @analyzer.stats.renderable_data[:structured]['Document::Element'][1][1].reporting_data.keys.include?(:default_values_without_coverage).should == true
  end
  
  it "should catch methods that have undocumented parameters." do
    @analyzer.stats.renderable_data[:structured]['Document::Element'][1][1].reporting_data.keys.include?(:parameters_without_coverage).should == true
  end
  
  it "should catch methods that have undocumented options hashes." do
    @analyzer.stats.renderable_data[:structured]['Document::Element'][1][1].reporting_data.keys.include?(:no_options_documentation).should == true
  end
  
  # Let's kill off the HTML!
  after(:all) do
    `chmod 744 coverage.html; rm coverage.html`
  end
  
end
