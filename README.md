Timekeeper
=========

Timekeeper is a storage and query server for time-series 'application' metrics.  Systems like Ganglia, Cactus and Nagios work well for 'technical' metrics like CPU usage, load average, RAM usage, etc.  Timekeeper wants to store the application metrics you'd use to monitor the health and well being of your website, for instance, # of logins, credit card transactions, search queries, etc.  Essentially anything you'd want to track by hostname (per machine) would be considered a 'technical' metric and not appropriate for Timekeeper.


Design
------------

Timekeeper provides the following functionality:

 - Server which provides APIs to write metric values and read aggregate metric data
 - Automatic aggregation of metric values into 5, 15, 60, 240 and 1440 minute buckets.
 - Warning and error visualization for metrics based on standard deviations from previous weeks' values.
 - Ruby client API
 - Javascript graphing library


Installation and Usage
------------------------

    gem install timekeeper

The Ruby client requires the 'faraday', 'typhoeus' and 'yajl-ruby'.  The APIs are just REST though so they can be written in any language that speaks HTTP.

Server requires 'mongo' and 'bson_ext'.


Author
----------

Mike Perham, mperham@gmail.com, [mikeperham.com](http://mikeperham.com), [@mperham](http://twitter.com/mperham).  I provide consulting services through my company, [Bootspring](http://bootspring.com).  If you need help with Timekeeper, Ruby performance and scalability, or general Ruby on Rails development, contact me and we'll see how I can help.  In general, I can set up a Timekeeper instance for much less money than it would take to pay a developer to write custom application metrics collection, aggregation and query functionality.


Copyright
-----------

Copyright (c) 2010 Mike Perham. See LICENSE for details.
