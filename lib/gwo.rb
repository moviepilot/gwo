require 'action_view/helpers/capture_helper'
module GWO
  module Helper

    include ::ActionView::Helpers::CaptureHelper
    

    def gwo_start(id, sections  = [], ignore=false)
      return "" if ignore

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
      end

      src
    end

    def gwo_end(id, uacct, ignore = false)
      return "" if ignore
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
      return "" if ignore
      %{
      <script type="text/javascript">
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
          var GWO_#{section} = utmx("variation_content", "#{section}");
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
      end
      src
    end
  end
end
