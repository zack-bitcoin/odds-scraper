Odds Scraper
=======

You need lynx installed to use this software.
Tested in Ubuntu 20.04

`sh get_odds.sh` loading the web page to a local file.

`sh start.sh` to turn on the server.

`sh attach.sh` to connect to the server's REPL.

While connected to REPL you can issue these commands
================

`halt().` to turn it off.

`sportsbookreview:reload()` to refresh the data.

`sportsbookreview:read()` to look at the data.

using the api
===========

`curl -i -d '["test", 1]' http://localhost:8084`

when you load the data from the api, all the words are base64 encoded.
you can base64 decode in javascript like this:
`Decoded = atob(Encoded);`

