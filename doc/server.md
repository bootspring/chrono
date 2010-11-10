Server
=========

The server provides a simple RESTful API for creating, reading and deleting application metric data.  The underlying datastore is MongoDB.  Raw metric data is taken from the client and pushed into a temporary collection, which is then aggregated every 5 minutes into data that can be queried for and displayed in the UI.