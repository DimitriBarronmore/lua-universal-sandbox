 local _ENV = _ENV if _VERSION < "Lua 5.2" then 	_ENV = (getfenv and getfenv()) or _G end		 --0
 local __export = {}  		 --0
----
local deepcopy --10
deepcopy = function ( o , seen ) --11
seen = seen or { } --12
if o == nil then --13
return nil end --13
if seen [ o ] then --14
return seen [ o ] end --14
local no --16
if _ENV.type ( o ) == 'table' then --17
no = { } --18
seen [ o ] = no --19
for k , v in _ENV.next , o , nil do --21
no [ deepcopy ( k , seen ) ] = deepcopy ( v , seen ) --22
end--23
_ENV.setmetatable ( no , deepcopy ( _ENV.getmetatable ( o ) , seen ) ) --24
else--25
no = o --26
end--27
return no --28
end--29
local initial_environment = { --33
_VERSION = _ENV._VERSION , --34
assert = _ENV.assert , --35
collectgarbage = _ENV.collectgarbage , --36
dofile = _ENV.dofile , --37
error = _ENV.error , --38
getmetatable = _ENV.getmetatable , --39
ipairs = _ENV.ipairs , --40
load = _ENV.load , --41
loadfile = _ENV.loadfile , --42
loadstring = _ENV.loadstring , --43
next = _ENV.next , --44
pairs = _ENV.pairs , --45
pcall = _ENV.pcall , --46
print = _ENV.print , --47
rawequal = _ENV.rawequal , --48
rawlen = _ENV.rawlen , --49
rawset = _ENV.rawset , --50
rawget = _ENV.rawget , --51
require = _ENV.require , --52
select = _ENV.select , --53
setmetatable = _ENV.setmetatable , --54
tonumber = _ENV.tonumber , --55
tostring = _ENV.tostring , --56
type = _ENV.type , --57
warn = _ENV.warn , --58
xpcall = _ENV.xpcall , --59
unpack = _ENV.unpack , --60
getfenv = _ENV.getfenv , --61
setfenv = _ENV.setfenv , --62
utf8 = deepcopy ( _ENV.utf8 ) , --63
coroutine = deepcopy ( _ENV.coroutine ) , --64
debug = deepcopy ( _ENV.debug ) , --65
io = deepcopy ( _ENV.io ) , --66
math = deepcopy ( _ENV.math ) , --67
os = deepcopy ( _ENV.os ) , --68
string = deepcopy ( _ENV.string ) , --69
package = deepcopy ( _ENV.package ) , --70
table = deepcopy ( _ENV.table ) , --71
}--72
local set_mt = { } --75
set_mt . __index = set_mt --76
function set_mt : add ( ... ) --77
for _ , element in _ENV.ipairs ( { ... } ) do --78
self [ element ] = true --79
end--80
end--81
function set_mt : remove ( ... ) --82
for _ , element in _ENV.ipairs ( { ... } ) do --83
self [ element ] = nil --84
end--85
end--86
function set_mt : removeall ( ) --87
for key in _ENV.pairs ( self ) do --88
self [ key ] = nil --89
end--90
end--91
function set_mt : add_from_table ( tab ) --92
for key in _ENV.pairs ( tab ) do --93
self [ key ] = true --94
end--95
end--96
local function new_set ( ) --98
return _ENV.setmetatable ( { } , set_mt ) --99
end--100
local template_mt = { } --108
template_mt . __index = template_mt --109
function template_mt : create_env ( ) --112
local environment = { } --113
if self . inherits then --114
local old_environment = self . inherits : create_env ( ) --115
for key in _ENV.pairs ( self . keeps ) do --116
local module , method = key : match ( '([^%.]+)%.([^%.]+)' ) --117
if module and old_environment [ module ] then --118
environment [ module ] = environment [ module ] or { } --119
environment [ module ] [ method ] = old_environment [ module ] [ method ] --120
else--121
environment [ key ] = old_environment [ key ] --122
end--123
end--127
old_environment = nil --128
end--131
for key , value in _ENV.pairs ( self . sets ) do --132
environment [ deepcopy ( key ) ] = deepcopy ( value ) --133
end--134
if self . special then --135
self . special ( environment ) --136
end--137
return environment --138
end--139
local sandboxes = { } --141
function sandboxes . clone ( original ) --144
local new = { } --145
new . __is_sandbox_template = true --146
new . keeps = new_set ( ) --147
new . sets = { } --148
new . inherits = original . inherits --149
for key in _ENV.pairs ( original . keeps ) do --150
new . keeps : add ( key ) --151
end--152
for key , value in _ENV.pairs ( original . sets ) do --153
new . sets [ key ] = value --154
end--155
new . special = original . special --156
new . _G = new --157
_ENV.setmetatable ( new , template_mt ) --158
return new --159
end--160
function sandboxes . new ( inherits , inherit_keeps ) --164
local new_template = { } --165
new_template . __is_sandbox_template = true --166
new_template . keeps = new_set ( ) --167
new_template . sets = { } --168
if inherits then --169
if inherits . __is_sandbox_template then --170
new_template . inherits = inherits --171
if inherit_keeps then --172
for key in _ENV.pairs ( inherits . keeps ) do --173
new_template . keeps : add ( key ) --174
end--175
end--176
else--177
_ENV.error ( "attempted to inherit from invalid parent" , 2 ) --178
end--179
end--180
new_template . _G = new_template --181
_ENV.setmetatable ( new_template , template_mt ) --182
return new_template --183
end--184
sandboxes . unsafe = sandboxes . new ( ) --186
sandboxes . unsafe . sets = initial_environment --187
sandboxes . restricted = sandboxes . new ( sandboxes . unsafe ) --191
sandboxes . restricted . keeps : add ( "_VERSION" , "assert" , "collectgarbage" , "error" , "ipairs" , "next" , --192
"pairs" , "pcall" , "print" , "select" , "tonumber" , "tostring" , "type" , --193
"warn" , "xpcall" , "unpack" , --194
"utf8.char" , "utf8.charpattern" , "utf8.codes" , "utf8.codepoint" , --195
"utf8.len" , "utf8.offset" , --196
"math.abs" , "math.acos" , "math.asin" , "math.atan" , "math.atan2" , --197
"math.ceil" , "math.floor" , "math.cos" , "math.cosh" , "math.deg" , --198
"math.exp" , "math.fmod" , "math.frexp" , "math.huge" , "math.ldexp" , --199
"math.log" , "math.log10" , "math.max" , "math.min" , "math.modf" , "math.pi" , --200
"math.pow" , "math.rad" , "math.random" , "math.sin" , "math.sinh" , --201
"math.sqrt" , "math.tan" , "math.tanh" , --202
"string.lower" , "string.upper" , "string.find" , --203
"string.match" , "string.gmatch" , "string.gsub" , "string.format" , --204
"string.len" , "string.byte" , "string.char" , "string.sub" , "string.rep" , --205
"string.reverse" , --206
"coroutine.status" , "coroutine.running" , "coroutine.isyieldable" , --207
"coroutine.create" , "coroutine.yield" , "coroutine.resume" , --208
"coroutine.wrap" , --209
"os.clock" , "os.difftime" , "os.time" , --210
"table.insert" , "table.maxn" , "table.remove" , "table.sort" --211
)--212
function sandboxes . _check_file_exists ( filename ) --215
local file = _ENV.io . open ( filename ) --216
if file then --217
file : close ( ) --218
return true --219
end--220
return false --221
end--222
sandboxes . _default_require_path = _ENV.package . path --224
local function filepath_search ( filepath ) --229
for path in _ENV.package . path : gmatch ( "[^;]+" ) do --230
local fixed_path = path : gsub ( "%?" , ( filepath : gsub ( "%." , "/" ) ) ) --231
if sandboxes . _check_file_exists ( fixed_path ) then --238
return fixed_path --239
end--240
end--241
end--242
local function return_lua_searcher ( env ) --244
local searcher = function ( modulepath ) --245
local filepath = filepath_search ( modulepath ) --246
if filepath then --247
return function ( reqpath ) --248
local chunk , err = env . loadfile ( filepath , "t" , env ) --249
if chunk then --250
return chunk , reqpath --251
else--252
_ENV.error ( "error loading module '" .. reqpath .. "'\n" .. ( err or "" ) , 0 ) --253
end--254
end --255
else--256
local err = ( "\n\tno file '%s.lua' in package.path" ) : format ( modulepath , 2 ) --257
return err --258
end--259
end--260
return searcher --261
end--262
local function create_require ( env ) --265
env . package = env . package or { } --266
env . package . searchers = { return_lua_searcher ( env ) } --267
env . package . preload = { } --268
env . package . loaded = { } --269
env . package . path = sandboxes . _default_require_path --270
env . require = function ( modname ) --272
if env . package . loaded [ modname ] then --273
return env . package . loaded [ modname ] --274
end--275
local loader --277
local errors = { } --278
if env . package . preload [ modname ] then --279
loader = env . package . preload [ modname ] --280
else--281
for _ , searcher in _ENV.ipairs ( env . package . searchers ) do --282
local result = searcher ( modname ) --283
if _ENV.type ( result ) == "function" then --284
loader = result --285
break--286
else--287
_ENV.table . insert ( errors , result ) --288
end--289
end--290
end--291
if loader == nil then --292
_ENV.error ( _ENV.table . concat ( errors ) ) --293
else--294
local status , res = _ENV.pcall ( loader , modname ) --295
if status == false or _ENV.type ( res ) ~= "function" then --296
_ENV.error ( res , 2 ) --297
end--298
local chunk = res --300
status , res = _ENV.pcall ( chunk , modname ) --301
if status == false then --302
_ENV.error ( "error loading module '" .. modname .. "'\n" .. res , 2 ) --303
end--304
if res == nil then --305
res = true --306
end--307
env . package . loaded [ modname ] = res --308
return res --309
end--310
end--311
end--312
local string_metatable = _ENV.getmetatable ( "" ) --314
sandboxes . protected = sandboxes . clone ( sandboxes . restricted ) --316
sandboxes . protected . keeps : add ( "setmetatable" , "rawset" , "rawget" , "rawlen" , "rawequal" , "string.dump" ) --317
sandboxes . protected . sets . getmetatable = function ( obj ) --318
local res = _ENV.getmetatable ( obj ) --319
if res ~= string_metatable then --320
return res --321
else--322
_ENV.error ( "attempt to get dangerous metatable from inside sandbox" , 2 ) --323
end--324
end--325
sandboxes . protected . special = function ( sbox ) --326
if _ENV._VERSION == "Lua 5.1" then --327
sbox . load = function ( a , b ) --328
local chunk , err = _ENV.load ( a , b ) --329
if chunk then --330
_ENV.setfenv ( chunk , sbox ) --330
end --330
return chunk , err --331
end--332
sbox . loadfile = function ( a ) --333
local chunk , err = _ENV.loadfile ( a ) --334
if chunk then --335
_ENV.setfenv ( chunk , sbox ) --335
end --335
return chunk , err --336
end--337
sbox . loadstring = function ( a ) --338
local chunk , err = _ENV.loadstring ( a ) --339
if chunk then --340
_ENV.setfenv ( chunk , sbox ) --340
end --340
return chunk , err --341
end--342
else--343
sbox . load = function ( a , b , c , env ) --344
if env == nil then --345
env = sbox --346
end--347
return _ENV.load ( a , b , c , env ) --348
end--349
sbox . loadfile = function ( a , b , env ) --350
if env == nil then --351
env = sbox --352
end--353
return _ENV.loadfile ( a , b , env ) --354
end--355
sbox . loadstring = function ( string , env ) --356
if env == nil then --357
env = sbox --358
end--359
return _ENV.load ( string , nil , "t" , env ) --360
end--361
end--362
sbox . dofile = function ( a ) --365
local chunk , err = sbox . loadfile ( a ) --366
if err then --367
_ENV.error ( err , 2 ) --367
end --367
return chunk ( ) --368
end--369
create_require ( sbox ) --370
end--371
local function test_print ( env ) --375
for k , v in _ENV.pairs ( env ) do --376
if k ~= "_G" then --377
if _ENV.type ( v ) == "table" then --378
local concat = { } --380
for j , l in _ENV.pairs ( v ) do --381
if _ENV.type ( l ) == "table" then --382
end--384
_ENV.table . insert ( concat , ( "%s.%s" ) : format ( k , j ) ) --386
end--387
_ENV.print ( _ENV.table . concat ( concat , "    " ) ) --388
else--389
_ENV.print ( ( "%s - %s" ) : format ( k , v ) ) --390
end--391
end--392
end--393
end--394
local environment = sandboxes . protected : create_env ( ) --415
local test_code = [[ 	apple = "yummy" 	pear = "fruity" 	lemon = "sour" 	load("print(apple)")() 	 	loadstring("print(pear)")() 	 	loadfile("tmp_test.lua")() 	print(apple) 	dofile("tmp_test.lua") 	print(require("tmp_test-require")) ]] --417
local chunk = _ENV.loadstring ( test_code ) --440
_ENV.setfenv ( chunk , environment ) --441
chunk ( ) --442
_ENV.print ( _ENV.apple , _ENV.pear , _ENV.lemon ) --443
---