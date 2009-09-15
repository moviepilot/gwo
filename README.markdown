NOTE: CURRENTLY THIS WORKS ONLY WITH HAML ... I HAVE TO FIX IT IN ORDER TO GET IT RUNNING WITH ERB


This is a Ruby on Rails plugin (gem) which simplifies Server-Side Dynamic Section Variations with 
[Google Website Optimizer](http://www.google.com/websiteoptimizer) as described in the article
[Server-Side Dynamic Section Variations on gwotricks.com](http://www.gwotricks.com/2009/05/server-side-dynamic-section-variations.html)

== Features: 
------------

* very good Ruby on Rails integration
* very simple to use
* support for several sections that should have different variants
* support for named and numbered sections
* include part of a page in more than one variant
* support for google analytics tracking
* kill-switch
* well tested


The 'Usage' may look long - but it's fairly straightforward and shouldn't take 5 mins.

Daniel Bornkessel gwo@bornkessel.com & Alex MacCaw - alex@madebymany.co.uk (original author)

== Usage
--------

To use GWO, you need two pages:
* A test page containing the multi variant sections
* A page that signifies conversion (i.e. account creation page)

[Signup for Google Website Optimizer and](http://www.google.com/websiteoptimizer):

 1.  Click create another experiment
 2.  Click multivariate experiment
 3.  Name it and enter the test/conversion urls
 4.  Select 'You will install and validate the JavaScript tags'
 5.  Ignore the scripts that are offered, but strip out your account id (uacct) and test id (both to be found in the Tracking Script).
     They look like as follows:
         var pageTracker=_gat._getTracker("UI-6882082-1");
         pageTracker._trackPageview("/1662461989/test");
     So, in this example the uacct is 'UA-6882082-1' and the test id is 1662461989.
 6.  Leave google and prepare your source code
 7.  Add the gwo_experiment tag around the code that is supposed to contain the variants (see the gwo_experiment documentation for
     possible options)
 8.  in the gwo_experiment you can specify one or more sections your side can contain. Each section can have several 
     variants. So if you have for example 2 sections with each having 3 variants you would have 6 different possible
     combinations on your page.
 9.  Create your gwo_sections, as in the example. The first parameter is the name of the section,
     the second the name of the variant(s) in which the following code should be shown (see example code).
     You can mix variants by just passing in more than one identifier. The 
     original variant has the reserved identifier :original (or 0 if you use numbers)
 10. The variants can either be identified by numbers (starting at 0 for the original variant) or be named (see below how to 
     assign the names in the google web interface).
 11. Add a gwo_conversion helper tag on your conversion page passing in your uacct and test id.
 12. In order to validate the pages in the goole web interface, start rails, surf to the pages (variant and conversion page) you 
     just created and save each one locally.
 13. back in the google web interface, validate your pages by using the 'offline validation' link and upload the two 
     pages you just saved
 14. as a next step, define the sections. If you used named identifiers in you rails source code, put the the identifiers
     name as the content of the variations in the web interface (i.e. the example below would have two variants (+ the original
     variant); one variation would have the CONTENT (subject & name of the variants are not important) 'minimalistic' and the other
     'with_sidebar_and_top_signup_box' (without the quotes)). If you use numbered identifiers, just create new variations and leave the 
     content empty.
 15. finish up and start the experiment
 16. lean back and let google collect data for you for the next few days ... go back an be shocked about the little number of
     conversions you will probably get ;)
 

== Example
----------
... in haml:

    = gwo_experiment("1662461989", "UA-6882082-1", :signup_box_test, :conditions => (signed_up? && country == "de")) do
      = gwo_section(:signup_box_test, [:with_sidebar_and_top_signup_box, :minimalistic], :ga_tracking => true, :conditions => (signed_up? && country == "de")) do
        = render :partial => 'gossib/signup'
        %span I am only visible in the variants :with_sidebar_and_top_signup_box and :minimalistic

      = gwo_section(:signup_box_test, [:original, :with_sidebar_and_top_signup_box], :conditions => (signed_up? && country == "de")) do
        = render :partial => 'gossib/bookmark_menu'
        = render :partial => 'gossip/pics', :locals => {:images       => @article.images}
        .box#
          %span Hi hi ... I am not visible in :minimalistic
    
      %span I am visible in every variation
    
      = gwo_section(:signup_box_test, :original, :conditions => (signed_up? && country == "de")) do
        %span I am only in the original page
  
... or in erb:

    <% gwo_experiment("1662461989", "UA-6882082-1", :signup_box_test, :conditions => (signed_up? && country == "de")) do %>
      <% render :partial => 'gossip/article.html.haml',  :object => @article %>
    
      <% gwo_section(:signup_box_test, [:with_sidebar_and_top_signup_box, :minimalistic], :conditions => (signed_up? && country == "de")) do %> 
        <%= render :partial => 'gossib/signup' %>
        <span> I am only visible in the variants :with_sidebar_and_top_signup_box and :minimalistic</span>
      <% end %>

      <% gwo_section(:signup_box_test, [:original, :with_sidebar_and_top_signup_box], :conditions => (signed_up? && country == "de")) do %>
        <%= render :partial => 'gossib/bookmark_menu' %>
        <%= render :partial => 'gossip/pics', :locals => {:images       => @article.images} %>
        <div class="box">
          <span> Hi hi ... I am not visible in :minimalistic</span>
      <% end %>
    
      <span> I am visible in every variation</span>
    
      <% gwo_section(:signup_box_test, :original, :conditions => (signed_up? && country == "de")) do %>
        <span> I am only in the original page</span>
      <% end %>
    <% end %>


== Conversion page:
------------------
... haml:

    = gwo_conversion('UA-23902382-1', '1909920434')

... erb:

    <%= gwo_conversion('UA-23902382-1', '1909920434') %>



Copyright (c) 2009 Made by Many, released under the MIT license
