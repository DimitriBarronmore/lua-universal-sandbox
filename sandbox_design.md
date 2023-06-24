
# requirements
- primary use is to return a plain lua table suitable for use as an environment to load code into
	- do not provide any builtin methods for loading code into a sandbox; trust the user to know best in that regard
- primary library function simply creates the environment from a specified template.
	- there is no default template; an included preset must be explicitly chosen
	- templates can be inherited from to create derivatives: copying off restricted or protected is recommended
	- templates come with methods/fields to finely manipulate what's in the sandbox
		- base list to copy key=val. inherits up the chain. child sandboxes can add script-type-specific values here.
		- blacklist/whitelist, oversees what's copied from the base list. parsed down the chain, so a child sandbox's final contents are the sum of all black/whitelists in order.
			- actually, this is dumb. let's just make each sandbox an explicit whitelist, and continually drop values from previous sandboxes in the chain.
		- callback which runs after an environment is created. allows users to add values which are unique to each sandbox and/or perform advanced crimes such as giving the environment a metatable. all callbacks in the inheritance chain are run in parent > child order.
- base templates represent multiple safety levels; sandboxes can be fully unprotected, protected with new wrapper functions, or fully restricted
	- unsafe modules include:
		- all file/string loading
		- get/setmetatable
		- get/setfenv
		- package.*
		- io.*
		- all of os except .clock, .date, .difftime, time
		- debug.*
	- modules replaced include:
		- require (reimplement to use sandbox)
		- package (see above; safe subset reimplemented)
		- load, loadfile, dofile, loadstring (reimplement to make the sandbox the default env)
		- get/setmetatable (error when trying to manipulate strings or userdata)
		- sandbox deep-copies the listed modules, with the exception of any blacklisted sub-modules/library methods
- the source from which the sandbox is copied is initialized internally when a sandbox template is created/modified, such that later changes to the global environment will not affect the sandbox contents

note: consider crossreferencing https://github.com/kikito/lua-sandbox/blob/master/sandbox.lua for list of safe values
note: mention use of __metatable in usage instructions

KIKITO SANDBOX
--[[
	_VERSION assert error    ipairs   next pairs
pcall    select tonumber tostring type unpack xpcall
coroutine.create coroutine.resume coroutine.running coroutine.status
coroutine.wrap   coroutine.yield
math.abs   math.acos math.asin  math.atan math.atan2 math.ceil
math.cos   math.cosh math.deg   math.exp  math.fmod  math.floor
math.frexp math.huge math.ldexp math.log  math.log10 math.max
math.min   math.modf math.pi    math.pow  math.rad   math.random
math.sin   math.sinh math.sqrt  math.tan  math.tanh
os.clock os.difftime os.time
string.byte string.char  string.find  string.format string.gmatch
string.gsub string.len   string.lower string.match  string.reverse
string.sub  string.upper
table.insert table.maxn table.remove table.sort
]]



----

SPECIAL VALUES:
Tables and values which need to be represented differently in each sandbox are added to the list as functions, marked in some way to be run. 


=====
redesign 2023-06-24

sandbox structure is as follows:
the base unit is a template. a template is not a sandbox, it is the pattern from which a sandbox is made.

a template has the following fields:
	- inherits : a parent template which the initializer builds and copies from as a key-value map, initially a base copy of the default environment.
	- keeps    : a Set whitelist, inherited by child templates. children can effect a blacklist by Removing elements, or use a helper function to clear the entire set and start over.
	- sets     : a key-value map which explicitly overwrites contents copied from the `inherits` list or adds new values to the environment.
	- special : a function `(env) -> nil` to run after the environment is built. the basemost function sets the environment's `_G` value to the table itself.

a blank template can be created with `sandboxes.new()`. you can provide a parent template as the one argument.

the library keeps reference to created sandbox templates, to ensure that only valid templates are used as parents.

creating a new environment is as follows:
	- run the `template:create_env()` function
	- if the template has a .inherits field, that template's `:create_env()` function is called and the result captured.
		- the basemost template from which the defaults inherit will return a deep-copied version of the basic Lua environment environment as it was when the library loaded.
	- if a parent was captured then for each key in the parent's table, if the key is not an element in `keeps`, discard it.
	- if the template does not have a `.inherits` field, a new empty table is instead created.
	- for each key in `.sets`, deep-copy it to the env table.
	- run the function `.special()` passing in the env table
	- return the env table.