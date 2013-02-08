%% eggs (Erlang Generic Game Server)
%%
%% Copyright (C) 2012-2013  Jordi Llonch <llonch.jordi at gmail dot com>
%%
%% This program is free software: you can redistribute it and/or modify
%% it under the terms of the GNU Affero General Public License as
%% published by the Free Software Foundation, either version 3 of the
%% License, or (at your option) any later version.
%%
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU Affero General Public License for more details.
%%
%% You should have received a copy of the GNU Affero General Public License
%% along with this program.  If not, see <http://www.gnu.org/licenses/>.

-module(eggs_entity_proplists).

%% API
-export([behaviour_info/1]).
-export([base_get/2, base_set/2, base_set/3]).
-export([initialize/2, get/2, set/2, set/3, get_module/1, get_id/1]).

behaviour_info(callbacks) ->
  [{initialize, 1}, {set, 3}, {set, 2}, {get, 2}];

behaviour_info(_) ->
  undefined.

initialize(Module, Data) ->
  lager:debug("Initializing entity ~p", [Module]),
  %% generate a proplist
  {Module, [{internal_id, make_ref()}] ++ Data}.

%% api used by callback module
base_get({_, Data}, Property) ->
  proplists:get_value(Property, Data).

base_set({Module, Data}, []) -> {Module, Data};
base_set({Module, Data}, [{Property, Value} | T]) ->
  {_, NewData} = base_set({Module, Data}, Property, Value),
  base_set({Module, NewData}, T).
base_set({Module, Data}, Property, Value) ->
  NewData = proplists:delete(Property, Data),
  {Module, NewData ++ [{Property, Value}]}.

%% public api
get_id(Entity) ->
  base_get(Entity, internal_id).

get(Entity, Property) ->
  {Module, _} = Entity,
  Module:get(Entity, Property).

set(Entity, Values) ->
  {Module, _} = Entity,
  Module:set(Entity, Values).
set(Entity, Property, Value) ->
  {Module, _} = Entity,
  Module:set(Entity, Property, Value).

get_module(Entity) ->
  {Module, _} = Entity,
  Module.
