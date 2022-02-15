-module(odds_scraper_sup).
-behaviour(supervisor).
-export([start_link/0]).
-export([init/1, stop/0]).
-define(SERVER, ?MODULE).
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%-define(CHILD(I, TYPE), #{id => 

-define(keys, [sportsbookreview
              ]).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).
child_killer([]) -> [];
child_killer([H|T]) -> 
    supervisor:terminate_child(amoveo_explorer_sup, H),
    child_killer(T).
stop() -> child_killer(?keys).
child_maker([]) -> [];
child_maker([H|T]) -> [?CHILD(H, worker)|child_maker(T)].

%% sup_flags() = #{strategy => strategy(),         % optional
%%                 intensity => non_neg_integer(), % optional
%%                 period => pos_integer()}        % optional
%% child_spec() = #{id => child_id(),       % mandatory
%%                  start => mfargs(),      % mandatory
%%                  restart => restart(),   % optional
%%                  shutdown => shutdown(), % optional
%%                  type => worker(),       % optional
%%                  modules => modules()}   % optional
init([]) ->
    SupFlags = #{strategy => one_for_all,
                 intensity => 0,
                 period => 1},
    %ChildSpecs = [],
    ChildSpecs = child_maker(?keys),
    {ok, {SupFlags, ChildSpecs}}.

%% internal functions
