require 'action_view/helpers/capture_helper'
module GWO
  module Helper

    include ::ActionView::Helpers::CaptureHelper
    
    def js_logger(text, with_js_tag = false)
      return "if(typeof(console.log) == 'function') console.log(#{text});" if RAILS_ENV != "test" && RAILS_ENV != "production" && !with_js_tag
      return "<script type='text/javascript'>if(typeof(console.log) == 'function') console.log(\"#{text}\");</script>" if RAILS_ENV != "test" && RAILS_ENV != "production" && with_js_tag
      return ""
    end

    def gwo_experiment(id, uacct, sections = [], ignore = false, &block)
      src  = gwo_start(id, sections, ignore)
      src += capture(&block) 
      src += gwo_end(id, uacct, ignore)
      src
    end


    def gwo_conversion(id, uacct, ignore = false)  
      return js_logger("skipping conversion snippet: a/b variation test switched off", true) if ignore 

      %{
      <script type="text/javascript">
      #{ js_logger("'conversion for test with id #{id} and uacct #{uacct}'") }
      if(typeof(_gat)!='object')document.write('<sc'+'ript src="http'+
      (document.location.protocol=='https:'?'s://ssl':'://www')+
      '.google-analytics.com/ga.js"></sc'+'ript>')</script>
      <script type="text/javascript">
      try {
      var pageTracker=_gat._getTracker("#{uacct}");
      pageTracker._trackPageview("/#{id}/goal");
      }catch(err){}</script>
      }

    end


    def gwo_section(section = "gwo_section", variation_ids = nil, ignore = false, &block)
      variation_ids = [*variation_ids].compact
      src = ""
      if is_default_section?(variation_ids)
        if ignore
          src += capture(&block)
        else
          conditions = (named_variations?(variation_ids) ? variation_ids.map{|x| "GWO_#{section}_name != \"#{x}\""} : variation_ids.map{|x| "GWO_#{section}_number != #{x}"}).join(" && ")

          src += %{ <script>
          if ( #{ conditions } ) document.write('<no' + 'script>');
          </script>
            #{capture(&block) if block_given?}
          </noscript>
          }
        end
      elsif not ignore
        if !variation_ids.empty?
          conditions = (named_variations?(variation_ids) ? variation_ids.map{|x| "GWO_#{section}_name == \"#{x}\""} : variation_ids.map{|x| "GWO_#{section}_number == #{x}"}).join(" || ") 
             
          src += %{<script>
          if ( #{ conditions } ) document.write('</noscript a="');
          </script><!--">
            #{capture(&block) if block_given?}
          <script>document.write('<'+'!'+'-'+'-')</script>-->
          }
        end
      else
        src =  js_logger("skipping snippet for #{variation_ids.join(", ")} variations: a/b variation test switched off", true) 
      end
      src
    end

    private
    def gwo_start(id, sections  = [], ignore=false)
      return js_logger("skipping start snippet: a/b variation test switched off", true) if ignore 


      sections = [*sections].compact.empty? ? ["gwo_section"] : [*sections]
      src = %{
        <script type='text/javascript'>
        function utmx_section(){}function utmx(){}
        (function(){var k='#{id}',d=document,l=d.location,c=d.cookie;function f(n){
        if(c){var i=c.indexOf(n+'=');if(i>-1){var j=c.indexOf(';',i);return c.substring(i+n.
        length+1,j<0?c.length:j)}}}var x=f('__utmx'),xx=f('__utmxx'),h=l.hash;
        d.write('<sc'+'ript src="'+
        'http'+(l.protocol=='https:'?'s://ssl':'://www')+'.google-analytics.com'
        +'/siteopt.js?v=1&utmxkey='+k+'&utmx='+(x?x:'')+'&utmxx='+(xx?xx:'')+'&utmxtime='
        +new Date().valueOf()+(h?'&utmxhash='+escape(h.substr(1)):'')+
        '" type="text/javascript" charset="utf-8"></sc'+'ript>')})();
        </script>
      }

      google_analytics_info = "";
      section_definitions = "";
      variable_assignments = "";

      sections.each do |section|
        section_definitions += "<!-- utmx section name='#{section}' -->\n"

        variable_assignments += %{
            var GWO_#{section}_name = utmx("variation_content", "#{section}");
            if( GWO_#{section}_name == undefined) GWO_#{section}_name = 'original';

            var GWO_#{section}_number = utmx("variation_number", "#{section}");
            if( GWO_#{section}_number == undefined) GWO_#{section}_number = 0;

            #{ js_logger("'variant: ' + GWO_#{section}_name") }
        }
        google_analytics_info += "google_analytics_info += \"|GWO_#{section}_name:\" + GWO_#{section}_name;"
      end

      variable_assignments += %{
         window.onload = function(){ 
          var google_analytics_info = ''; #{google_analytics_info}; if(typeof(trackPageView) == 'function') {
            trackPageView(document.location + "?ab_test_variant=" + google_analytics_info);
            #{js_logger('document.location + "?ab_test_variant=" + google_analytics_info')}
          }
        }
      }

      variable_assignments = "<script type='text/javascript'>#{variable_assignments}</script>";

      "#{src}#{section_definitions}#{variable_assignments}"
    end
    
    def gwo_end(id, uacct, ignore = false)
      return js_logger("skipping end snippet: a/b variation test switched off", true) if ignore 

      %{<script type="text/javascript">
      if(typeof(_gat)!='object')document.write('<sc'+'ript src="http'+
      (document.location.protocol=='https:'?'s://ssl':'://www')+
      '.google-analytics.com/ga.js"></sc'+'ript>')</script>
      <script type="text/javascript">
      try {
      var pageTracker=_gat._getTracker("#{uacct}");
      pageTracker._trackPageview("/#{id}/test");
      }catch(err){}</script>
      }

    end

    def is_default_section?(variation_ids)
      variation_ids.include?(:original) || variation_ids.include?(0)
    end

    def named_variations?(variation_ids)
      raise RuntimeError.new("variation ids can only be either string, symbols or numbers") if [*variation_ids].compact.empty?   # catch empty hashes and nil

      return false if [1, *variation_ids].map(&:class).uniq.length                 == 1  # all variation_ids are FixNums
      return true  if ["string", :symbol, *variation_ids].map(&:class).uniq.length == 2  # all variation_ids are either string or symbol

      raise RuntimeError.new("variation ids can only be either string, symbols or numbers")
    end
  end

end
