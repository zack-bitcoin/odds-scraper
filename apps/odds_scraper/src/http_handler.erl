-module(http_handler).

-export([init/2, init/3, handle/2, terminate/3, doit/1]).

%curl -i -d '[-6,"test", 1]' http://localhost:8084

init(Req, State) ->
	  handle(Req, State).
handle(Req, State) ->
    {ok, Data, _} = cowboy_req:read_body(Req),
    true = is_binary(Data),
    A = packer:unpack(Data),
    B = doit(A),
    D = packer:pack(B),
    Headers = #{<<"content-type">> => <<"application/octet-stream">>,
    <<"Access-Control-Allow-Origin">> => <<"*">>},
    Req2 = cowboy_req:reply(200, Headers, D, Req),
    {ok, Req2, State}.
init(_Type, Req, _Opts) -> {ok, Req, no_state}.
terminate(_Reason, _Req, _State) -> ok.
doit({test, 1}) ->
    LoT = sportsbookreview:read(),%list of tuples
    LoL = lists:map(fun(X) ->
                            tuple_to_list(X)
                    end, LoT),
    Lo1 = lists:foldl(fun(A, B) ->
                              A ++ B
                      end, [], LoL),
    {ok, Lo1}.
    
    
