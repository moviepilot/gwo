require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'lib/gwo'

describe GWO do
  include GWO::Helper

  describe "gwo_start method" do
    it "should produce correct output" do
      gwo_start("gwo_id", "section_name").should =~ /utmx section name='section_name'/
      gwo_start("gwo_id", "section_name").should =~ /k='gwo_id'/
    end

    it "should work with just the id parameter set" do
      gwo_start("gwo_id").should =~ /k='gwo_id'/
      gwo_start("gwo_id").should =~ /utmx section name='gwo_section'/
      gwo_start("gwo_id", nil).should =~ /utmx section name='gwo_section'/
    end

    it "should work with one single section ... section is a symbol" do
      gwo_start("gwo_id", :section_name).should =~ /utmx section name='section_name'/
      gwo_start("gwo_id", :section_name).should =~ /k='gwo_id'/
    end

    it "should work with an array of section" do
      gwo_start("gwo_id", ["body",:content,"footer"]).should =~ /utmx section name='body'/
      gwo_start("gwo_id", ["body",:content,"footer"]).should =~ /utmx section name='content'/
      gwo_start("gwo_id", ["body",:content,"footer"]).should =~ /utmx section name='footer'/
    end

    it "should return nothing when ignore is set to true" do
      gwo_start("id", [], true).should == "" 
      gwo_start("gwo_id", ["body",:content,"footer"], true).should == ""
    end
  end

  describe "gwo_end method" do
    it "should produce correct output" do
      gwo_end("gwo_id", "gwo_uacct").should =~ /getTracker\(\"gwo_uacct\"\)/
      gwo_end("gwo_id", "gwo_uacct").should =~ /trackPageview\(\"\/gwo_id\/test\"\)/
    end

    it "should return nothing if ignore is set to true" do
      gwo_end("gwo_id", "gwo_uacct", true).should_not =~ /getTracker\(\"gwo_uacct\"\)/
      gwo_end("gwo_id", "gwo_uacct", true).should == ""
    end
  end

  describe "gw_conversion method" do
    it "should produce correct output" do
      gwo_conversion("gwo_id", "gwo_uacct").should =~ /getTracker\(\"gwo_uacct\"\)/
      gwo_conversion("gwo_id", "gwo_uacct").should =~ /trackPageview\(\"\/gwo_id\/goal\"\)/
    end

    it "should return nothing when ignore is set to true" do
      gwo_conversion("gwo_id", "gwo_uacct", true).should == ""
    end
  end

  describe "gwo_section method" do
      
    it "should return nothing when ignore is set to true and the variation is not the default" do
      gwo_section("gwo_section", ["foo","bar"], true).should == ""
    end

    it "should return default output without javascript if ignore is true and default is the variation " do
      gwo_section("gwo_section", :default, true) { "this is the content" }.should == "this is the content"
    end

    it "should return default output with javascript if ignore is unset and default is the variation " do
      gwo_section("gwo_section", :default) { "this is the content" }.should =~ /this is the content/
      gwo_section("gwo_section", :default) { "this is the content" }.should =~ /utmx\(\"variation_content\", \"gwo_section\"\)/
      gwo_section("gwo_section", :default) { "this is the content" }.should =~ /( GWO_gwo_section != undefined )/
    end

    it "should only write one javascript block if the section is used for default and variations" do
      gwo_section("section", [:default, :variation1, :variation2]) { "this is the content" }.should     =~ /this is the content/
      gwo_section("section", [:default, :variation1, :variation2]) { "this is the content" }.should     =~ /utmx\(\"variation_content\", \"section\"\)/
      gwo_section("section", [:default, :variation1, :variation2]) { "this is the content" }.should     =~ /( GWO_section != \"variation1\" && GWO_section != \"variation2\" && GWO_section != undefined )/
    end

    it "should write block for one variant" do
      gwo_section("section",:testing) { "this is the content" }.should     =~ /this is the content/ 
      gwo_section("section",:testing) { "this is the content" }.should_not =~ /utmx\(\"variation_content\", \"section\"\)/
      gwo_section("section",:testing) { "this is the content" }.should     =~ /( GWO_section == \"testing\" )/
    end

    it "should write one block but enabled for all given variants " do
      gwo_section("section",[:testing, :still_testing]) { "this is the content" }.should     =~ /this is the content/ 
      gwo_section("section",[:testing, :still_testing]) { "this is the content" }.should_not =~ /utmx\(\"variation_content\", \"section\"\)/
      gwo_section("section",[:testing, :still_testing]) { "this is the content" }.should     =~ /( GWO_section == \"testing\" || GWO_section == \"still_testing\" )/
    end
  end
  
end
