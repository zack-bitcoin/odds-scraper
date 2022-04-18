-module(cron).
-export([doit/1, reload/0]).

%We want to re-download from the website every time the full node finds a new block. and re-generage the JSON.

-define(MinRequestPeriod, 20000).%20 seconds
-define(BlockCheckPeriod, 2000).%2 seconds


reload() ->
    io:fwrite("reload"),
    os:cmd("sh ../../../../get_odds2.sh > ../../../../sportsbookreview"),
    timer:sleep(3000),
    sportsbookreview:reload().

talk(X) ->
    talker:talk(X, {{127,0,0,1}, 8081}).

doit(N) ->
    spawn(fun() -> loop(N) end).

loop(N) ->
    %look up current block height. if it is bigger than n, we need to reload.
    {ok, M} = talk({height}),
    case M of
        N -> timer:sleep(?BlockCheckPeriod);
        _ -> 
            spawn(fun() -> reload() end),
            timer:sleep(?MinRequestPeriod)
    end,
    loop(M).
