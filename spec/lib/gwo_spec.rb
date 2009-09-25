require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'lib/gwo'

describe GWO do
  include GWO::Helper

  describe "google analytics stuff" do
    it "should not create any google analytics stuff by default" do
      gwo_start("gwo_id", "section_name").should_not =~ /google_analytics_info \+= \"&section_name=\" \+ GWO_section_name_name;/
      gwo_start("gwo_id", "section_name").should_not =~ /gwoGaPageTracker\(document.location \+ \"\?ab_test=gwo_id\" \+ google_analytics_info\)/
    end
    it "should not create google analytics stuff if option is disabled" do
      gwo_start("gwo_id", "section_name").should_not =~ /google_analytics_info \+= \"&section_name=\" \+ GWO_section_name_name;/
      gwo_start("gwo_id", "section_name").should_not =~ /gwoGaPageTracker\(document.location \+ \"\?ab_test=gwo_id\" \+ google_analytics_info\)/
    end

    it "should create correct google analytics stuff for default urls" do
      gwo_start("gwo_id", "section_name", :google_analytics => {:account_id => "123456789"}).should =~ /google_analytics_info \+= \"&section_name=\" \+ GWO_section_name_name;/
      gwo_start("gwo_id", "section_name", :google_analytics => {:account_id => "123456789"}).should =~ /gwoGaPageTracker._trackPageview\(document.location \+ \"\?ab_test=gwo_id\" \+ google_analytics_info\)/
    end

    it "should create correct google analytics stuff for static urls" do
      gwo_start("gwo_id", "section_name", :google_analytics => {:account_id => "123456789", :virtual_url => "http://example.com"}).should =~ 
        /google_analytics_info \+= \"&section_name=\" \+ GWO_section_name_name;/
      gwo_start("gwo_id", "section_name", :google_analytics => {:account_id => "123456789", :virtual_url => "http://example.com"}).should =~ 
         /var gwoGaPageTracker=_gat._getTracker\(\"123456789\"\);/
      gwo_start("gwo_id", "section_name", :google_analytics => {:account_id => "123456789", :virtual_url => "http://example.com"}).should =~ 
        /gwoGaPageTracker._trackPageview\(\"http:\/\/example\.com\" \+ \"\?ab_test=gwo_id\" \+ google_analytics_info\)/
    end

    it "should create correct google analytics stuff for several sections" do
      gwo_start("gwo_id", ["section_name1", "section_name2", "section_name3"], :google_analytics => {:account_id => "123456789"}).should =~ /google_analytics_info \+= \"&section_name1=\" \+ GWO_section_name1_name;/
      gwo_start("gwo_id", ["section_name1", "section_name2", "section_name3"], :google_analytics => {:account_id => "123456789"}).should =~ /google_analytics_info \+= \"&section_name2=\" \+ GWO_section_name2_name;/
      gwo_start("gwo_id", ["section_name1", "section_name2", "section_name3"], :google_analytics => {:account_id => "123456789"}).should =~ /google_analytics_info \+= \"&section_name3=\" \+ GWO_section_name3_name;/
      gwo_start("gwo_id", ["section_name1", "section_name2", "section_name3"], :google_analytics => {:account_id => "123456789"}).should =~ /gwoGaPageTracker._trackPageview\(document.location \+ \"\?ab_test=gwo_id\" \+ google_analytics_info\)/
    end

  end

  describe "named_variations? method" do
    it "should return false if one numbered variation is passed in" do
      named_variations?(1).should == false
    end
    it "should return false if variations are numbered" do
      named_variations?([1,2,3]).should == false
    end

    it "should return true if one string is passed in" do
      named_variations?("string").should == true
    end
    it "should return true if one symbol is passed in" do
      named_variations?(:symbol).should == true
    end
    it "should return true if symbols and strings are mixed" do
      named_variations?([:symbol, "string", :symbol2]).should == true
    end
    it "should throw an exception if numbers and strings are mixed" do
      lambda {named_variations?([1, :symbol])}.should           raise_error(RuntimeError)
      lambda {named_variations?([1, "string"])}.should          raise_error(RuntimeError)
      lambda {named_variations?([1, "string", :symbol])}.should raise_error(RuntimeError)
    end
    it "should throw an exception if one obscure object is passed in" do
      lambda {named_variations?(Hash.new)}.should         raise_error(RuntimeError)
      lambda {named_variations?(RuntimeError.new)}.should raise_error(RuntimeError)
    end
    it "should throw an exception if an array of obscure object is passed in" do
      lambda {named_variations?([{}, {}])}.should raise_error(RuntimeError)
    end
  end

  describe "gwo_start method" do
    it "should produce correct output" do
      gwo_start("gwo_id", "section_name").should =~ /utmx section name='section_name'/
      gwo_start("gwo_id", "section_name").should =~ /utmx\(\"variation_content\", \"section_name\"\)/
      gwo_start("gwo_id", "section_name").should =~ /utmx\(\"variation_number\", \"section_name\"\)/
      gwo_start("gwo_id", "section_name").should =~ /k='gwo_id'/
    end

    it "should work with just the id parameter set" do
      gwo_start("gwo_id").should =~ /k='gwo_id'/
      gwo_start("gwo_id").should =~ /utmx section name='gwo_section'/
      gwo_start("gwo_id").should =~ /utmx\(\"variation_content\", \"gwo_section\"\)/
      gwo_start("gwo_id").should =~ /utmx\(\"variation_number\", \"gwo_section\"\)/
      gwo_start("gwo_id", nil).should =~ /utmx section name='gwo_section'/
    end

    it "should work with one single section ... section is a symbol" do
      gwo_start("gwo_id", :section_name).should =~ /utmx section name='section_name'/
      gwo_start("gwo_id", :section_name).should =~ /utmx\(\"variation_content\", \"section_name\"\)/
      gwo_start("gwo_id", :section_name).should =~ /utmx\(\"variation_number\", \"section_name\"\)/
      gwo_start("gwo_id", :section_name).should =~ /k='gwo_id'/
    end

    it "should work with an array of section" do
      gwo_start("gwo_id", ["body",:content,"footer"]).should =~ /utmx section name='body'/
      gwo_start("gwo_id", ["body",:content,"footer"]).should =~ /utmx section name='content'/
      gwo_start("gwo_id", ["body",:content,"footer"]).should =~ /utmx section name='footer'/

      gwo_start("gwo_id", ["body",:content,"footer"]).should =~ /utmx\(\"variation_content\", \"body\"\)/
      gwo_start("gwo_id", ["body",:content,"footer"]).should =~ /utmx\(\"variation_content\", \"content\"\)/
      gwo_start("gwo_id", ["body",:content,"footer"]).should =~ /utmx\(\"variation_content\", \"footer\"\)/

      gwo_start("gwo_id", ["body",:content,"footer"]).should =~ /utmx\(\"variation_number\", \"body\"\)/
      gwo_start("gwo_id", ["body",:content,"footer"]).should =~ /utmx\(\"variation_number\", \"content\"\)/
      gwo_start("gwo_id", ["body",:content,"footer"]).should =~ /utmx\(\"variation_number\", \"footer\"\)/
    end

    it "should return nothing when conditions return false" do
      gwo_start("id", [], {:conditions => false}).should == "" 
      gwo_start("gwo_id", ["body",:content,"footer"], :conditions => false).should == ""

      gwo_start("gwo_id", ["body",:content,"footer"], {:conditions => false}).should_not =~ /utmx\(\"variation_content\", \"body\"\)/
      gwo_start("gwo_id", ["body",:content,"footer"], {:conditions => false}).should_not =~ /utmx\(\"variation_content\", \"content\"\)/
      gwo_start("gwo_id", ["body",:content,"footer"], {:conditions => false}).should_not =~ /utmx\(\"variation_content\", \"footer\"\)/
      
      gwo_start("gwo_id", ["body",:content,"footer"], :conditions => false).should_not =~ /utmx\(\"variation_number\",  \"body\"\)/
      gwo_start("gwo_id", ["body",:content,"footer"], :conditions => false).should_not =~ /utmx\(\"variation_number\",  \"content\"\)/
      gwo_start("gwo_id", ["body",:content,"footer"], :conditions => false).should_not =~ /utmx\(\"variation_number\",  \"footer\"\)/
    end
  end

  describe "gwo_end method" do
    it "should produce correct output" do
      gwo_end("gwo_id", "gwo_uacct", :conditions => true).should =~ /getTracker\(\"gwo_uacct\"\)/
      gwo_end("gwo_id", "gwo_uacct", :conditions => true).should =~ /trackPageview\(\"\/gwo_id\/test\"\)/
    end

    it "should return nothing if conditions are not met" do
      gwo_end("gwo_id", "gwo_uacct", {:conditions => false}).should_not =~ /getTracker\(\"gwo_uacct\"\)/
      gwo_end("gwo_id", "gwo_uacct", :conditions => false).should == ""
    end
  end

  describe "gw_conversion method" do
    it "should produce correct output" do
      gwo_conversion("gwo_id", "gwo_uacct").should =~ /getTracker\(\"gwo_uacct\"\)/
      gwo_conversion("gwo_id", "gwo_uacct").should =~ /trackPageview\(\"\/gwo_id\/goal\"\)/
    end

    it "should return nothing when conditions are not met" do
      gwo_conversion("gwo_id", "gwo_uacct", {:conditions => false}).should == ""
    end
  end

  describe "gwo_section method with named sections" do
      
    it "should return nothing when conditions are not met and the variation is not the original" do
      gwo_section("gwo_section", ["foo","bar"], {:conditions => false}).should == ""
    end

    it "should return original output without javascript if conditions are not met and original is the variation " do
      gwo_section("gwo_section", :original, {:conditions => false}) { "this is the content" }.should == "this is the content"
    end

    it "should return original output with javascript if ignore is unset and original is the variation " do
      gwo_section("gwo_section", :original) { "this is the content" }.should =~ /this is the content/
      gwo_section("gwo_section", :original) { "this is the content" }.should =~ /( GWO_gwo_section_name != \"original\" )/
    end

    it "should only write one javascript block if the section is used for original and variations" do
      gwo_section("section", [:original, :variation1, :variation2]) { "this is the content" }.should     =~ /this is the content/
      gwo_section("section", [:original, :variation1, :variation2]) { "this is the content" }.should     =~ /( GWO_section_name != \"original\" && GWO_section_name != \"variation1\" && GWO_section_name != \"variation2\" )/
    end

    it "should write block for one variant" do
      gwo_section("section",:testing) { "this is the content" }.should     =~ /this is the content/ 
      gwo_section("section",:testing) { "this is the content" }.should     =~ /( GWO_section_name == \"testing\" )/
    end

    it "should write one block but enabled for all given variants " do
      gwo_section("section",[:testing, :still_testing]) { "this is the content" }.should     =~ /this is the content/ 
      gwo_section("section",[:testing, :still_testing]) { "this is the content" }.should     =~ /( GWO_section_name == \"testing\" || GWO_section_name == \"still_testing\" )/
    end
  end

  describe "gwo_section method with numbered sections" do
      
    it "should return nothing when conditions are not met and the variation is not the original" do
      gwo_section("gwo_section", [1, 2], {:conditions => false}).should == ""
    end

    it "should return original output without javascript if conditions are not met and original is the variation " do
      gwo_section("gwo_section", 0, {:conditions => false}) { "this is the content" }.should == "this is the content"
    end

    it "should return original output with javascript if ignore is unset and original is the variation " do
      gwo_section("gwo_section", 0) { "this is the content" }.should =~ /this is the content/
      gwo_section("gwo_section", 0) { "this is the content" }.should =~ /( GWO_gwo_section_number != 0 )/
    end

    it "should only write one javascript block if the section is used for original and variations" do
      gwo_section("section", [0, 1, 2]) { "this is the content" }.should     =~ /this is the content/
      gwo_section("section", [0, 1, 2]) { "this is the content" }.should     =~ /( GWO_section_number != 0 && GWO_section_number != 1 && GWO_section_number != 2 )/
    end

    it "should write block for one variant" do
      gwo_section("section",1) { "this is the content" }.should     =~ /this is the content/ 
      gwo_section("section",1) { "this is the content" }.should     =~ /( GWO_section_number == 1 )/
    end

    it "should write one block but enabled for all given variants " do
      gwo_section("section",[1, 2]) { "this is the content" }.should     =~ /this is the content/ 
      gwo_section("section",[1, 2]) { "this is the content" }.should     =~ /( GWO_section_number == 1 || GWO_section_number == 2 )/
    end
  end
  
end
