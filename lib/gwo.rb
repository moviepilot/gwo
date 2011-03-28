# Author::    Alex MacCaw - alex AT madebymany DOT co DOT uk (original), Daniel Bornkessel - daniel AT bornkessel DOT com
# License::   MIT
# :include:README.markdown
#
#

require 'action_view/helpers/capture_helper'
require 'action_view/helpers/tag_helper'
module GWO
  module Helper

    include ::ActionView::Helpers::CaptureHelper
    include ::ActionView::Helpers::TagHelper
     
    # start a gwo_experiment 
    #
    # Params: 
    # * <b>id</b>       the id of the experiment (in the google Tracking Script look for something like <tt>pageTracker._trackPageview("/<ID>/test");</tt> )
    # * <b>uacct</b>    account number (in the google Tracking Script look for something like <tt>var pageTracker=_gat._getTracker("<UACCT>");</tt> )
    # * <b>sections</b> name of the section(s) your page will include; pass in one symbol/string or an array of symbols/strings here
    # * <b>options</b>  hash of possible options:
    #   * <b>:conditions</b>  if set to false, the experiment won't be executed -- only the source code of the :original (or 0) variants would be shown. No JavaScript code will be produced. It serves as a kill switch for the gwo experiment. If, for example, you only want to execute an experiment for users that are not logged in, you could pass <tt>:conditions => !logged_in?</tt> here.
    #   * <b>:google_analytics</b> a hash for google analytics tracking: it will call the google analytics script with either the document.location or a virtual url if you provide it. At the end of the url, gwo appends information about which a/b test was executed and which section was the user had in the form of url parameters (s.th. like <tt> http://&lt;url&gt;?ab_test=&lt;id&gt;&section=&lt;section name &gt; </tt>)
    #     * <b>:account_number</b> the google analytics account id where the tracking should take place
    #     * <b>:virtual_url</b> if you want to choose a different tracking url then the document.location for tracking
    #     * <b>:goal_is_bounce_rate</b> if true, every click on a link on the current view is counted as a goal (NOTE: this includes external links as well)
    def gwo_experiment(id, uacct, sections = [], options = {}, &block)
      options = {
        :conditions => (ENV['RAILS_ENV'] == 'test' ? false : true),
        :goal_is_bounce_rate => false
      }.update(options)

      src  = gwo_start(id, sections, options)
      src += capture(&block) if block
      src += gwo_end(id, uacct, options)

      if options[:goal_is_bounce_rate]
        src +=<<JS
<script type="text/javascript"><!--
    function addEvent( obj, type, fn ) {
       if (obj.addEventListener) {
          obj.addEventListener( type, fn, false );
       } else if (obj.attachEvent) {
          obj["e"+type+fn] = fn;
          obj[type+fn] = function() { obj["e"+type+fn]( window.event ); }
          obj.attachEvent( "on"+type, obj[type+fn] );
       }
    }

    
    addEvent(document, "click", function(event) { 
      if( event.target.nodeName === "A" ) {
        #{js_logger("'bounce rate goal reached'")}
        try {
          var gwoPageTracker=_gat._getTracker("#{uacct}");
          gwoPageTracker._trackPageview("/#{id}/goal");
        }catch(err){}
      }
    });
    #{js_logger("'set goal to bounce rate minimization'")}
  //-->
</script>
JS
      end

      src
    end


    # to be included on the conversion page. 
    #
    # Params: 
    # * <b>id</b> & <b>uacct</b> see gwo_experiment
    # * <b>options</b>
    #   * :conditions as in gwo_experiment
    def gwo_conversion(id, uacct, options = {})  
      options = {
        :conditions => (ENV['RAILS_ENV'] == 'test' ? false : true)
      }.update(options)

      return js_logger("skipping conversion snippet: a/b variation test switched off", true) if options[:conditions] == false

      %{
      <script type="text/javascript">
      #{ js_logger("'conversion for test with id #{id} and uacct #{uacct}'") }
      if(typeof(_gat)!='object')document.write('<sc'+'ript src="http'+
      (document.location.protocol=='https:'?'s://ssl':'://www')+
      '.google-analytics.com/ga.js"></sc'+'ript>')</script>
      <script type="text/javascript">
      try {
      var gwoPageTracker=_gat._getTracker("#{uacct}");
      gwoPageTracker._trackPageview("/#{id}/goal");
      }catch(err){}</script>
      }

    end


    # identify a section which is only visible in certain variants
    #
    # Params:
    # * <b>section</b> name of the section
    # * <b>variation_ids</b> identifiers of the variants in which this content is to be shown. Can be either a name of the variant (== the <b><i>content</i></b> of a variant in the GWO web interface) or a number. The original content has the reserved name <tt>:original</tt> or the number <tt>0</tt> respectivly. If the content should be shown in more than one variant, pass in an array of identifiers. Mixing numbered and named variant ids will result in an exception.
    # * <b>options</b>
    #   * :conditions as in gwo_experiment
    def gwo_section(section = "gwo_section", variation_ids = nil, options = {}, &block)
      options = {
        :conditions => (ENV['RAILS_ENV'] == 'test' ? false : true)
      }.update(options)

      variation_ids = [*variation_ids].compact
      src = ""
      if is_default_section?(variation_ids)
        if options[:conditions] == false
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
      elsif options[:conditions] == true
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
    def js_logger(text, with_js_tag = false)
      return "if(typeof(console.log) == 'function') console.log(#{text});" if RAILS_ENV != "test" && RAILS_ENV != "production" && !with_js_tag
      return "<script type='text/javascript'>if(typeof(console.log) == 'function') console.log(\"#{text}\");</script>" if RAILS_ENV != "test" && RAILS_ENV != "production" && with_js_tag
      return ""
    end

    def gwo_start(id, sections  = [], options = {})

      return js_logger("skipping start snippet: a/b variation test switched off", true) if options[:conditions] == false


      sections = [*sections].compact.empty? ? ["gwo_section"] : [*sections]
      src = %{
        <script type='text/javascript'>
        function utmx_section(){}function utmx(){}
        (function(){var k='#{id}',d=document,l=d.location,c=d.cookie;function f(n){
        if(c){var i=c.indexOf(n+'=');if(i>-1){var j=c.indexOf(';',i);return escape(c.substring(i+n.
        length+1,j<0?c.length:j))}}}var x=f('__utmx'),xx=f('__utmxx'),h=l.hash;
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
            var GWO_#{section}_name = utmx("variation_content", "#{section}");if( GWO_#{section}_name == undefined) GWO_#{section}_name = 'original';
            var GWO_#{section}_number = utmx("variation_number", "#{section}");if( GWO_#{section}_number == undefined) GWO_#{section}_number = 0;
            #{ js_logger("'variant: ' + GWO_#{section}_name") }
        }
        google_analytics_info += "google_analytics_info += \"&#{section}=\" + GWO_#{section}_name;" if options[:google_analytics]
      end

      # GOOGLE TRACKER:
      if options[:google_analytics]
        base_url = options[:google_analytics][:virtual_url] ? "\"#{options[:google_analytics][:virtual_url]}\"" : "document.location"
        variable_assignments += %{
          window.onload = function(){ 
            var google_analytics_info = ''; #{google_analytics_info};
            try{
              var gwoGaPageTracker=_gat._getTracker("#{options[:google_analytics][:account_id]}");
              gwoGaPageTracker._trackPageview(#{base_url} + "?ab_test=#{id}" + google_analytics_info);
            }catch(err){ #{js_logger("\"error executing google analytics request\"")} }
            #{js_logger("\"tracking \" + #{base_url} + \"?ab_test=#{id}\" + google_analytics_info + \" to account #{options[:google_analytics][:account_id]}\"")}
          }
        }
      end

      variable_assignments = "<script type='text/javascript'>#{variable_assignments}</script>";

      "#{src}#{section_definitions}#{variable_assignments}"
    end
    
    def gwo_end(id, uacct, options)
      return js_logger("skipping end snippet: a/b variation test switched off", true) if options[:conditions] == false

      %{<script type="text/javascript">
      if(typeof(_gat)!='object')document.write('<sc'+'ript src="http'+
      (document.location.protocol=='https:'?'s://ssl':'://www')+
      '.google-analytics.com/ga.js"></sc'+'ript>')</script>
      <script type="text/javascript">
      try {
      var gwoPageTracker=_gat._getTracker("#{uacct}");
      gwoPageTracker._trackPageview("/#{id}/test");
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
