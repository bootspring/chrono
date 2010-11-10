Metrics
===============

Timekeeper is designed to aggregate and store *application metrics*, not technical metrics.  What is an application metric?  It's very simple: a number which is not associated with a particular machine and can be aggregated by summing all the values in a given time period.

Let's look at a simple example: user logins.  You want to track how many user logins you get for a given time period.  You might have 4 app servers with 4 processes each, where each app server process is running a Timekeeper client.  Every minute, each instance will send the number of logins processed in the last minute.  Assuming each process handles 2 logins, that will be 16 metric values of 2 or a total sum of 32 logins processed in the last minute.  When you look at the UI, you will simply see 32 for the value of 'user logins' for that minute.

How you implement the metrics collection and push the metrics to the server is up to you.  Some people might use a cron job running every 1 or 5 minutes to collect and send the values.