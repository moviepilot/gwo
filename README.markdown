This is a Ruby on Rails plugin (gem) which simplifies Server-Side Dynamic Section Variations with 
[Google Website Optimizer](http://www.google.com/websiteoptimizer) as described on in the article
[Server-Side Dynamic Section Variations on gwotricks.com](http://www.gwotricks.com/2009/05/server-side-dynamic-section-variations.html)

== Features: 
------------

* very good Ruby on Rails integration
* very simple to use
* support for several sections that should have different variants
* support for named and numbered sections
* include part of a page in more than one variant
* support for <b>google analytics</b> tracking
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
5.   Ignore the scripts that are offered, but strip out your account id (uacct) and test id (in the Tracking Script).
     They look like this:
        var pageTracker=_gat._getTracker("UI-6882082-1");
        pageTracker._trackPageview("/1662461989/test");
     So, in this example the uacct is 'UA-6882082-1' and the test id is 1662461989.
6.  Add the gwo_experiment tag around the code that is supposed to contain the variants
7.  Create your gwo_sections, as in the example.
8.  Add the helper method 'gwo' before the closing </body> tag, passing the default section, uacct and test id as arguments.
9.  Deploy and validate the scripts in GWO
10. Enter sections for each of the named gwo_section helper tags, the content of the section should look like this:
    GWO("section_name")
11. Add a gwo_conversion helper tag on your conversion page passing in your uacct and test id.
12. Deploy and complete GWO wizard
13. Start recording stats & profit!


== Example
----------
... in haml:

  = gwo_experiment("1662461989", "UA-6882082-1", :signup_box_test, :conditions => (signed_up? && country == "de")) do
    = gwo_section(:signup_box_test, [:with_sidebar_and_top_signup_box, :minimalistic], :conditions => (signed_up? && country == "de")) do
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
