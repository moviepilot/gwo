NOTE: THIS VERSION HAS DRIFTED AWAY QUITE A BIT FROM THE ORIGINAL GWO PLUGIN ... I'LL UPDATE DOCUMENTATION SHORTLY, BUT THE WHOLE THING DOES NOT HAVE TO DO VERY MUCH WITH THE ORIGINAL GWO

GWO
===

Rails plugin for Google Website Optimizer which easily allows AB testing.
http://www.google.com/websiteoptimizer

This plugin also allows dynamic content, which GWO doesn't natively support.

The 'Usage' may look long - but it's fairly straightforward and shouldn't take 5 mins.

Alex MacCaw - alex@madebymany.co.uk

Usage
=====

To use GWO, you need two pages:
* A test page containing the AB sections
* A page that signifies conversion (i.e. account creation page)

Signup for GWO and:
1.  Click create another experiment
2.  Click multivariate experiment
3.  Name it and enter the test/conversion urls
4.  Select 'You will install and validate the JavaScript tags'
5.   Ignore the scripts that are offered, but strip out your account id (uacct) and test id (in the Tracking Script).
     They look like this:
       _uacct = 'UA-6882082-1';
       urchinTracker("/1662461989/test");
     So, in this example the uacct is 'UA-6882082-1' and the test id is 1662461989.
6.  Add the gwo_start tag after your opening <body> tag, passing your uacct.
7.  Create your gwo_sections, as in the example.
8.  Add the helper method 'gwo' before the closing </body> tag, passing the default section, uacct and test id as arguments.
9.  Deploy and validate the scripts in GWO
10. Enter sections for each of the named gwo_section helper tags, the content of the section should look like this:
    GWO("section_name")
11. Add a gwo_conversion helper tag on your conversion page passing in your uacct and test id.
12. Deploy and complete GWO wizard
13. Start recording stats & profit!


Example
=======

  <% gwo_section(:main) do %>
    Some default dynamic content <%= Time.now.to_i %>
  <% end %>

  <% gwo_section(:main2) do %>
    Some different dynamic content <%= Time.now.to_i %>
  <% end %>

  <% gwo_section(:main3) do %>
    Some really good dynamic content <%= Time.now.to_i %>
  <% end %>

  <%= gwo(:main, 'UA-23902382-1', 1909920434) %>

Conversion page
===============

  <%= gwo_conversion('UA-23902382-1', 1909920434) %>


Copyright (c) 2009 Made by Many, released under the MIT license
