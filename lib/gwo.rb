require 'action_view/helpers/capture_helper'
module GWO
  module Helper

    include ::ActionView::Helpers::CaptureHelper
    
    def js_logger(text, with_js_tag = false)
      return "if(typeof(console.log) == 'function') console.log(#{text})" if RAILS_ENV != "test" && RAILS_ENV != "development" && !with_js_tag
      return "<script type='text/javascript'>if(typeof(console.log) == 'function') console.log(\"#{text}\")</script>" if RAILS_ENV != "test" && with_js_tag
      return ""
    end

    def gwo_experiment(id, uacct, sections = [], ignore = false, &block)
      src  = gwo_start(id, sections, ignore)
      src += capture(&block) 
      src += gwo_end(id, uacct, ignore)
      src
    end

    def gwo_start(id, sections  = [], ignore=false)
      return js_logger("skipping start snippet: a/b variation test switched off", true) if ignore 


      sections = [*sections].compact.empty? ? ["gwo_section"] : [*sections]
      src = %{
        <script type="text/javascript">
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

      sections.each do |section|
        src += "<!-- utmx section name='#{section}' -->"
        src += %{
          <script type="text/javascript"><!--
            var GWO_#{section} = utmx("variation_content", "#{section}");
            #{ js_logger("'variant: ' + (GWO_#{section} == undefined ? 'default variant' : GWO_#{section})") }
            if(typeof(trackPageView) == 'function') trackPageView(document.location + "?ab_test_variant=" + (GWO_#{section} == undefined ? 'default_variant' : GWO_#{section}));
          //-->
          </script>
        }
      end

      src
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


    def gwo_section(section = "gwo_section", variation_numbers = nil, ignore = false, &block)
      variation_numbers = [*variation_numbers].compact
      src = ""
      if variation_numbers.include?(:default) || variation_numbers.empty?
        variation_numbers.delete(:default)
        if ignore
          src += capture(&block)
        else
          src += %{ <script>
          if ( #{ (variation_numbers.map{|x| "GWO_#{section} != \"#{x}\""} + ["GWO_#{section} != undefined"]).join(" && ")} ) document.write('<no' + 'script>');
          </script>
            #{capture(&block) if block_given?}
          </noscript>
          }
        end
      elsif not ignore
        if !variation_numbers.empty?
          src += %{<script>
          if ( #{variation_numbers.map{|x| "GWO_#{section} == \"#{x}\""}.join(" || ")} ) document.write('</noscript a="');
          </script><!--">
            #{capture(&block) if block_given?}
          <script>document.write('<'+'!'+'-'+'-')</script>-->
          }
        end
      else
        src =  js_logger("skipping snippet for #{variation_numbers.join(", ")} variations: a/b variation test switched off", true) 
      end
      src
    end
  end
end
