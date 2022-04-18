-module(sportsbookreview).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,
         reload/0, read/0
]).
init(ok) -> {ok, []}.
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, _) -> io:format("died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast(reload, _) -> 
    {noreply, reload2()};
handle_cast(_, X) -> {noreply, X}.
handle_call(read, _From, X) -> 
    {reply, X, X};
handle_call(_, _From, X) -> {reply, X, X}.

reload() ->
    gen_server:cast(?MODULE, reload).
read() ->
    gen_server:call(?MODULE, read).

reload2() ->
    %os:cmd("sh ../../../../get_odds.sh"),
    {ok, F} = file:read_file("../../../../sportsbookreview"),
    {match,  [_|TableEnds0]} =  re:run(F, "   \\[\\d+\\][^\n]+\n   Opener", [global, {capture, all}]),
    {match, Dates1} = re:run(F, "   Opener\n   [^\n]+\n", [global, {capture, all, binary}]),
    Dates = lists:map(fun(T) ->
                              T2 = re:replace(T, "   Opener\n   ", ""),
                              iolist_to_binary(T2)
                      end, Dates1),

    TableEnds = lists:map(fun([{X, _}]) -> X end, TableEnds0),
    Tables = cut_tables(TableEnds, F),
    Titles = 
        lists:map(fun(X) ->
                          {match, [[L]]} = re:run(X, "   \\[\\d+\\][^\n]+\n   Opener", [global, {capture, all, binary}]),
                          L2 = re:replace(L, "\n   Opener", ""),
                          L3 = re:replace(L2, "   \\[\\d+\\]", ""),
                          iolist_to_binary(L3)
                  end, Tables),
    %io:fwrite("before tables\n"),
    %io:fwrite(Tables),
    %io:fwrite("\n"),
    %io:fwrite("after tables \n"),
    Games = 
        lists:map(
          fun(X) ->
                  %case re:run(X, "[^\n]+\n   \\[\\d+\\][^\n]+\n[^\n]+\n   \\(BUTTON\\) Options\n((?=(?!eventLink))[\\w\\W])*", [global, {capture, all, binary}]) of
                  case re:run(X, "[^\n]+\n   (\\(\\d+\\) )?\\[\\d+\\][^\n]+\n[^\n]+\n   \\(BUTTON\\) Options\n((?=(?!eventLink))[\\w\\W])*", [global, {capture, all, binary}]) of
                  %case re:run(X, "[^\n]+\n   \\[\\d+\\][^\n]+\n([^\n]+\n)?   \\(BUTTON\\) Options\n", [global, {capture, all, binary}]) of
                      nomatch ->
                          io:fwrite("nomatch\n"),
                          io:fwrite(X),
                          io:fwrite("no match end\n"),
                          io:fwrite("\n"),
                          <<>>;
                      {match, L} ->
                          %{match, L} = 
                          %re:run(X, "[^\n]+\n   \\[\\d+\\][^\n]+\n[^\n]+\n   \\(BUTTON\\) Options\n((?=(?!eventLink))[\\w\\W])*", [global, {capture, all, binary}]),
                          %re:run(X, "[^\n]+\n   \\[\\d+\\][^\n]+\n[^\n]+\n   \\(BUTTON\\) Options\n", [global, {capture, all, binary}]),
                          L2 = lists:map(
                    fun([Game|_]) ->
                            Game2a = iolist_to_binary(re:replace(Game, "\n\n", "\n", [global])),
                            {match, Game2b} = re:run(Game2a, "((?=(?!18.. Gamble Responsibly))[\\w\\W])*", [{capture, all, binary}]),
                            Game2c = iolist_to_binary(Game2b),
                            Game2 = iolist_to_binary(re:replace(Game2c, "   ", "", [global])),
                            Game3 = iolist_to_binary(re:replace(Game2, "\\[\\d+\\]", "", [global])),
                            Game4 = iolist_to_binary(re:replace(Game3, "\\(BUTTON\\) Options\n", "", [global])),
                            Game5 = iolist_to_binary(re:replace(Game4, "\n$", "", [global])),
                            Game6 = iolist_to_binary(re:replace(Game5, "\n", ", ", [global])),
                            Game7 = iolist_to_binary(re:replace(Game6, ", \\]$", "", [global])),
                            Game8 = iolist_to_binary(re:replace(Game7, " \\(\\d+\\)", "", [global])),
                            Game9 = iolist_to_binary(re:replace(Game8, ", \\[ \\]", "", [global])),
                            Game10 = iolist_to_binary(re:replace(Game9, ", Final", "", [global])),
                            Game11 = iolist_to_binary(re:replace(Game10, ", 00", "", [global])),
                            Game12 = iolist_to_binary(re:replace(Game11, " -, Time", "", [global])),
                            %io:fwrite("round \n"),
                            %io:fwrite(iolist_to_binary(Game7)),
                            %io:fwrite("\n"),
                            [Game12, "; "]
                            
                            %binary:split(Game4, <<"\n">>, [global])
                    end, L),
                          iolist_to_binary(L2)
                  end
                              %G1 = binary:split(X, <<"   00\n   00\n">>, [global]),
                          %lists:map(fun(X) ->
                              %re:run(X, "   \d\d\d\n   \d\d\d\n", [global, {capture, all, binary}])
                  %end, G1)
          end, Tables),
    lists:zipwith3(fun(T, Gs, D) ->
                          {T, Gs, D}
                  end, Titles, Games, Dates).
    %Games.

split(Loc, Binary) ->
    L8 = Loc*8,
    <<B1:L8, B2/binary>> = Binary,
    {<<B1:L8>>, B2}.

cut_tables([H|T], F) ->
    {A, _} = split(H, F),
    [A|cut_tables2([H|T], F)].
cut_tables2([X], F) ->
    {_, B} = split(X, F),
    [B];
cut_tables2([A, B|T], F) ->
    {X, _} = split(B, F),
    {_, H} = split(A, X),
    [H|cut_tables2([B|T], F)].



unused() ->
    F = 0,
    {match, L} = re:run(F, "\\[\\d{1,4}\\][^\n|]+\n   \\d{1,4}\n   \\[\\d{1,4}\\][^\n|]+\n[^\n]+\n[^\n]+\n[^\n]+\n[^\n]+\n[^\n]+\n[^\n]+\n[^\n]+\n[^\n]+\n[^\n]+\n[^\n]+\n[^\n]+\n", [global, {capture, all, binary}]),
    L2 = lists:map(fun(X) ->
                           A = iolist_to_binary(re:replace(hd(X), "\n[^\n]+\n", "")),
                           B = iolist_to_binary(re:replace(A, "\n[^\n]+\n", "")),
                           Y = iolist_to_binary(re:replace(B, "\n", <<"">>, [global])),
                           iolist_to_binary(re:replace(Y, "\\[\\d+\\]", "", [global]))
                   end, L),
    L2.
    
                           
