Client
=========

The client runs on a machine or within a process and collects application metrics to send to the server.  The client can send metrics as frequently or infrequently as you wish, but no faster than once per minute.

A simple Ruby client API is provided as part of this project.  The client and server communicate via HTTP and JSON though so really any language can be used.