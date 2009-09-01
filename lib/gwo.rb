module GWO
  module Helper
    def gwo_start(id, *sections)
      sections = ["gwo_section"] if sections.blank?
        
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
    
    def gwo_end(uacct, id)
      %{<script type="text/javascript">
      if(typeof(_gat)!='object')document.write('<sc'+'ript src="http'+
      (document.location.protocol=='https:'?'s://ssl':'://www')+
      '.google-analytics.com/ga.js"></sc'+'ript>')</script>
      <script type="text/javascript">
      try {
      var pageTracker=_gat._getTracker("#{uacct.inspect}");
      pageTracker._trackPageview("/#{id}/test");
      }catch(err){}</script>
    }
    
    end
    
    def gwo_conversion(uacct, id)  
      %{
      <script type="text/javascript">
      if(typeof(_gat)!='object')document.write('<sc'+'ript src="http'+
      (document.location.protocol=='https:'?'s://ssl':'://www')+
      '.google-analytics.com/ga.js"></sc'+'ript>')</script>
      <script type="text/javascript">
      try {
      var pageTracker=_gat._getTracker("#{uacct.inspect}");
      pageTracker._trackPageview("/#{id}/goal");
      }catch(err){}</script>
      }
      
    end

    
    def gwo_section(section = "gwo_section", variation_number = nil, &block)
      if variation_number == nil
        %{ <script>
        var GWO_#{section} = utmx("variation_number", "#{section}");
        if (GWO_#{section} != undefined && GWO_#{section} != 0) document.write('<no' + 'script>');
        </script>
        #{capture(&block) if block_given?}
        </noscript>
        }
      else
        %{<script>
        if (GWO_#{section} == #{variation_number}) document.write('</noscript a="');
        </script><!--">
        #{capture(&block) if block_given?}
        <script>document.write('<'+'!'+'-'+'-')</script>-->
        }
      end
    end

    private
    
      # I'm overriding this since GWO doesn't like the CDATA section for some reason...
      def javascript_tag(content_or_options_with_block = nil, html_options = {}, &block)
        content =
          if block_given?
            html_options = content_or_options_with_block if content_or_options_with_block.is_a?(Hash)
            capture(&block)
          else
            content_or_options_with_block
          end
        tag = content_tag(:script, content, html_options.merge(:type => Mime::JS))
        if false # block_called_from_erb?(block)
          concat(tag)
        else
          tag
        end
      end
    
      def script(name, &block)
        javascript_tag("utmx_section(#{name.to_s.inspect})") + yield + "</noscript>"
      end
  end
end
