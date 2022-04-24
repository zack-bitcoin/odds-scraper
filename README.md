Odds Scraper
=======

You need lynx installed to use this software.
Tested in Ubuntu 20.04

`sh get_odds.sh` loading the web page to a local file.

`sh start.sh` to turn on the server.

`sh attach.sh` to connect to the server's REPL.

hold the control key and click the D key to disconnect from the REPL.


While connected to REPL you can issue these commands
================

`halt().` to turn it off.

`cron:doit()` to automatically refresh the betting odds, every time a block is added to the Amoveo blockchain. This only works if there is an Amoveo full node running on the same computer and it is using port 8081 for it's internal API.

`sportsbookreview:reload()` to read the html of the sportsbookreview website from a local file where 'get_odds.sh' had stored it. Convert it to JSON.

`sportsbookreview:read()` returns a stored copy of the JSON version of the data from the sports book review website.

using the api
===========

`curl -i -d '["test", 1]' http://localhost:8084`

when you load the data from the api, all the words are base64 encoded.
you can base64 decode in javascript like this:
`Decoded = atob(Encoded);`

Here is example code of using javascript to decode what you get from the server, stored in the variable `DATA`.

```
DATA
 .slice(1)
 .map(function(x){
        return(atob(x));
        });
```

You can see it in context in the included [example javascript code.](js/example.js)
