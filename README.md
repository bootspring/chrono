Chrono
=========

Chrono is a storage and query server for time-series 'application' metrics.  Systems like Ganglia, Cactus and Nagios work well for 'technical' metrics like CPU usage, load average, RAM usage, etc.  Chrono wants to store the application metrics you'd use to monitor the health and well being of your website, for instance, # of logins, credit card transactions, search queries, etc.  Essentially anything you'd want to track by hostname (per machine) would be considered a 'technical' metric and not appropriate for Chrono.


Design
------------

Chrono provides the following functionality:

 - Server which provides REST APIs to write metric values and read aggregate metric data
 - Automatic aggregation of metric values into 5, 15, 60, 240 and 1440 minute buckets.
 - Warning and error visualization for metrics based on standard deviations from values in previous time periods.
 - Sample Ruby client for the REST API
 - Javascript graphing library

Chrono does everything in UTC.  The UI does not have provisions for local time zones; the idea is that distributed team communication is so much easier when everyone uses the same standard time zone.


Installation and Usage
------------------------

    gem install timekeeper

The server and client are all included in the gem.  The Server uses Sinatra + MongoDB.


Author
----------

Mike Perham, mperham@gmail.com, [mikeperham.com](http://mikeperham.com), [@mperham](http://twitter.com/mperham).  I provide consulting services through my company, [Bootspring](http://bootspring.com).  If you need help with Chrono, Ruby performance and scalability, or general Ruby on Rails development, give us a ring.


Copyright
-----------

Copyright (c) 2010 Mike Perham. See LICENSE for details.
