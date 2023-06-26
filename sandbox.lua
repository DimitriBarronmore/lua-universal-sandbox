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
function set_mt : add_from_table ( tab , prefix ) --92
prefix = prefix or "" --93
for key , val in _ENV.pairs ( tab ) do --94
if _ENV.type ( val ) == "table" and prefix == "" then --95
self : add_from_table ( val , key .. "." ) --96
else--97
self [ prefix .. key ] = true --98
end--99
end--100
end--101
local function new_set ( ) --103
return _ENV.setmetatable ( { } , set_mt ) --104
end--105
local template_mt = { } --113
template_mt . __index = template_mt --114
function template_mt : create_env ( ) --117
local environment = { } --118
if self . inherits then --119
local old_environment = self . inherits : create_env ( ) --120
for key in _ENV.pairs ( self . keeps ) do --121
local module , method = key : match ( '([^%.]+)%.([^%.]+)' ) --122
if module and old_environment [ module ] then --123
environment [ module ] = environment [ module ] or { } --124
environment [ module ] [ method ] = old_environment [ module ] [ method ] --125
else--126
environment [ key ] = old_environment [ key ] --127
end--128
end--132
old_environment = nil --133
end--136
for key , value in _ENV.pairs ( self . sets ) do --137
environment [ deepcopy ( key ) ] = deepcopy ( value ) --138
end--139
environment . _G = environment --140
if self . special then --141
self . special ( environment ) --142
end--143
return environment --144
end--145
local sandboxes = { } --147
function sandboxes . clone ( original ) --150
local new = { } --151
new . __is_sandbox_template = true --152
new . keeps = new_set ( ) --153
new . sets = { } --154
new . inherits = original . inherits --155
for key in _ENV.pairs ( original . keeps ) do --156
new . keeps : add ( key ) --157
end--158
for key , value in _ENV.pairs ( original . sets ) do --159
new . sets [ key ] = value --160
end--161
new . special = original . special --162
_ENV.setmetatable ( new , template_mt ) --163
return new --164
end--165
function sandboxes . new ( parent , inherit_whitelist ) --169
local new_template = { } --170
new_template . __is_sandbox_template = true --171
new_template . keeps = new_set ( ) --172
new_template . sets = { } --173
if parent then --174
if parent . __is_sandbox_template then --175
new_template . inherits = parent --176
if inherit_whitelist then --177
for key in _ENV.pairs ( parent . keeps ) do --178
new_template . keeps : add ( key ) --179
end--180
end--181
else--182
_ENV.error ( "attempted to inherit from invalid parent" , 2 ) --183
end--184
end--185
_ENV.setmetatable ( new_template , template_mt ) --186
return new_template --187
end--188
sandboxes . unsafe = sandboxes . new ( ) --190
sandboxes . unsafe . sets = initial_environment --191
sandboxes . restricted = sandboxes . new ( sandboxes . unsafe ) --195
sandboxes . restricted . keeps : add ( "_VERSION" , "assert" , "error" , "ipairs" , "next" , --196
"pairs" , "pcall" , "print" , "select" , "tonumber" , "tostring" , "type" , --197
"warn" , "xpcall" , "unpack" , --198
"utf8.char" , "utf8.charpattern" , "utf8.codes" , "utf8.codepoint" , --199
"utf8.len" , "utf8.offset" , --200
"math.abs" , "math.acos" , "math.asin" , "math.atan" , "math.atan2" , --201
"math.ceil" , "math.floor" , "math.cos" , "math.cosh" , "math.deg" , --202
"math.exp" , "math.fmod" , "math.frexp" , "math.huge" , "math.ldexp" , --203
"math.log" , "math.log10" , "math.max" , "math.min" , "math.modf" , "math.pi" , --204
"math.pow" , "math.rad" , "math.random" , "math.sin" , "math.sinh" , --205
"math.sqrt" , "math.tan" , "math.tanh" , --206
"string.lower" , "string.upper" , "string.find" , --207
"string.match" , "string.gmatch" , "string.gsub" , "string.format" , --208
"string.len" , "string.byte" , "string.char" , "string.sub" , --209
"string.reverse" , --210
"coroutine.status" , "coroutine.running" , "coroutine.isyieldable" , --211
"coroutine.create" , "coroutine.yield" , "coroutine.resume" , --212
"coroutine.wrap" , --213
"os.clock" , "os.difftime" , "os.time" , --214
"table.insert" , "table.maxn" , "table.remove" , "table.sort" --215
)--216
function sandboxes . _check_file_exists ( filename ) --219
local file = _ENV.io . open ( filename ) --220
if file then --221
file : close ( ) --222
return true --223
end--224
return false --225
end--226
sandboxes . _default_require_path = _ENV.package . path --228
local function filepath_search ( filepath ) --233
for path in _ENV.package . path : gmatch ( "[^;]+" ) do --234
local fixed_path = path : gsub ( "%?" , ( filepath : gsub ( "%." , "/" ) ) ) --235
if sandboxes . _check_file_exists ( fixed_path ) then --242
return fixed_path --243
end--244
end--245
end--246
local function return_lua_searcher ( env ) --248
local searcher = function ( modulepath ) --249
local filepath = filepath_search ( modulepath ) --250
if filepath then --251
return function ( reqpath ) --252
local chunk , err = env . loadfile ( filepath , "t" , env ) --253
if chunk then --254
return chunk , reqpath --255
else--256
_ENV.error ( "error loading module '" .. reqpath .. "'\n" .. ( err or "" ) , 0 ) --257
end--258
end --259
else--260
local err = ( "\n\tno file '%s.lua' in package.path" ) : format ( modulepath , 2 ) --261
return err --262
end--263
end--264
return searcher --265
end--266
local function create_require ( env ) --269
env . package = env . package or { } --270
env . package . searchers = { return_lua_searcher ( env ) } --271
env . package . preload = { } --272
env . package . loaded = { } --273
env . package . path = sandboxes . _default_require_path --274
env . require = function ( modname ) --276
if env . package . loaded [ modname ] then --277
return env . package . loaded [ modname ] --278
end--279
local loader --281
local errors = { } --282
if env . package . preload [ modname ] then --283
loader = env . package . preload [ modname ] --284
else--285
for _ , searcher in _ENV.ipairs ( env . package . searchers ) do --286
local result = searcher ( modname ) --287
if _ENV.type ( result ) == "function" then --288
loader = result --289
break--290
else--291
_ENV.table . insert ( errors , result ) --292
end--293
end--294
end--295
if loader == nil then --296
_ENV.error ( _ENV.table . concat ( errors ) ) --297
else--298
local status , res = _ENV.pcall ( loader , modname ) --299
if status == false or _ENV.type ( res ) ~= "function" then --300
_ENV.error ( res , 2 ) --301
end--302
local chunk = res --304
status , res = _ENV.pcall ( chunk , modname ) --305
if status == false then --306
_ENV.error ( "error loading module '" .. modname .. "'\n" .. res , 2 ) --307
end--308
if res == nil then --309
res = true --310
end--311
env . package . loaded [ modname ] = res --312
return res --313
end--314
end--315
end--316
local string_metatable = _ENV.getmetatable ( "" ) --318
sandboxes . protected = sandboxes . clone ( sandboxes . restricted ) --320
sandboxes . protected . keeps : add ( "setmetatable" , "rawset" , "rawget" , "rawlen" , "rawequal" , "string.dump" , --321
"string.rep" , "collectgarbage" ) --322
sandboxes . protected . sets . getmetatable = function ( obj ) --323
if _ENV.type ( obj ) == "table" then --324
return _ENV.getmetatable ( obj ) --325
else--326
_ENV.error ( "attempt to get dangerous metatable from inside sandbox" , 2 ) --327
end--328
end--329
sandboxes . protected . special = function ( sbox ) --330
if _ENV._VERSION == "Lua 5.1" then --331
sbox . load = function ( a , b ) --332
local chunk , err = _ENV.load ( a , b ) --333
if chunk then --334
_ENV.setfenv ( chunk , sbox ) --334
end --334
return chunk , err --335
end--336
sbox . loadfile = function ( a ) --337
local chunk , err = _ENV.loadfile ( a ) --338
if chunk then --339
_ENV.setfenv ( chunk , sbox ) --339
end --339
return chunk , err --340
end--341
sbox . loadstring = function ( a ) --342
local chunk , err = _ENV.loadstring ( a ) --343
if chunk then --344
_ENV.setfenv ( chunk , sbox ) --344
end --344
return chunk , err --345
end--346
else--347
sbox . load = function ( a , b , c , env ) --348
if env == nil then --349
env = sbox --350
end--351
return _ENV.load ( a , b , c , env ) --352
end--353
sbox . loadfile = function ( a , b , env ) --354
if env == nil then --355
env = sbox --356
end--357
return _ENV.loadfile ( a , b , env ) --358
end--359
sbox . loadstring = function ( string , env ) --360
if env == nil then --361
env = sbox --362
end--363
return _ENV.load ( string , nil , "t" , env ) --364
end--365
end--366
sbox . dofile = function ( a ) --369
local chunk , err = sbox . loadfile ( a ) --370
if err then --371
_ENV.error ( err , 2 ) --371
end --371
return chunk ( ) --372
end--373
create_require ( sbox ) --374
end--375
return sandboxes --377
---