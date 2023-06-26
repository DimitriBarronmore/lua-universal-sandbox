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
if self . special then --140
self . special ( environment ) --141
end--142
return environment --143
end--144
local sandboxes = { } --146
function sandboxes . clone ( original ) --149
local new = { } --150
new . __is_sandbox_template = true --151
new . keeps = new_set ( ) --152
new . sets = { } --153
new . inherits = original . inherits --154
for key in _ENV.pairs ( original . keeps ) do --155
new . keeps : add ( key ) --156
end--157
for key , value in _ENV.pairs ( original . sets ) do --158
new . sets [ key ] = value --159
end--160
new . special = original . special --161
new . _G = new --162
_ENV.setmetatable ( new , template_mt ) --163
return new --164
end--165
function sandboxes . new ( inherits , inherit_keeps ) --169
local new_template = { } --170
new_template . __is_sandbox_template = true --171
new_template . keeps = new_set ( ) --172
new_template . sets = { } --173
if inherits then --174
if inherits . __is_sandbox_template then --175
new_template . inherits = inherits --176
if inherit_keeps then --177
for key in _ENV.pairs ( inherits . keeps ) do --178
new_template . keeps : add ( key ) --179
end--180
end--181
else--182
_ENV.error ( "attempted to inherit from invalid parent" , 2 ) --183
end--184
end--185
new_template . _G = new_template --186
_ENV.setmetatable ( new_template , template_mt ) --187
return new_template --188
end--189
sandboxes . unsafe = sandboxes . new ( ) --191
sandboxes . unsafe . sets = initial_environment --192
sandboxes . restricted = sandboxes . new ( sandboxes . unsafe ) --196
sandboxes . restricted . keeps : add ( "_VERSION" , "assert" , "error" , "ipairs" , "next" , --197
"pairs" , "pcall" , "print" , "select" , "tonumber" , "tostring" , "type" , --198
"warn" , "xpcall" , "unpack" , --199
"utf8.char" , "utf8.charpattern" , "utf8.codes" , "utf8.codepoint" , --200
"utf8.len" , "utf8.offset" , --201
"math.abs" , "math.acos" , "math.asin" , "math.atan" , "math.atan2" , --202
"math.ceil" , "math.floor" , "math.cos" , "math.cosh" , "math.deg" , --203
"math.exp" , "math.fmod" , "math.frexp" , "math.huge" , "math.ldexp" , --204
"math.log" , "math.log10" , "math.max" , "math.min" , "math.modf" , "math.pi" , --205
"math.pow" , "math.rad" , "math.random" , "math.sin" , "math.sinh" , --206
"math.sqrt" , "math.tan" , "math.tanh" , --207
"string.lower" , "string.upper" , "string.find" , --208
"string.match" , "string.gmatch" , "string.gsub" , "string.format" , --209
"string.len" , "string.byte" , "string.char" , "string.sub" , --210
"string.reverse" , --211
"coroutine.status" , "coroutine.running" , "coroutine.isyieldable" , --212
"coroutine.create" , "coroutine.yield" , "coroutine.resume" , --213
"coroutine.wrap" , --214
"os.clock" , "os.difftime" , "os.time" , --215
"table.insert" , "table.maxn" , "table.remove" , "table.sort" --216
)--217
function sandboxes . _check_file_exists ( filename ) --220
local file = _ENV.io . open ( filename ) --221
if file then --222
file : close ( ) --223
return true --224
end--225
return false --226
end--227
sandboxes . _default_require_path = _ENV.package . path --229
local function filepath_search ( filepath ) --234
for path in _ENV.package . path : gmatch ( "[^;]+" ) do --235
local fixed_path = path : gsub ( "%?" , ( filepath : gsub ( "%." , "/" ) ) ) --236
if sandboxes . _check_file_exists ( fixed_path ) then --243
return fixed_path --244
end--245
end--246
end--247
local function return_lua_searcher ( env ) --249
local searcher = function ( modulepath ) --250
local filepath = filepath_search ( modulepath ) --251
if filepath then --252
return function ( reqpath ) --253
local chunk , err = env . loadfile ( filepath , "t" , env ) --254
if chunk then --255
return chunk , reqpath --256
else--257
_ENV.error ( "error loading module '" .. reqpath .. "'\n" .. ( err or "" ) , 0 ) --258
end--259
end --260
else--261
local err = ( "\n\tno file '%s.lua' in package.path" ) : format ( modulepath , 2 ) --262
return err --263
end--264
end--265
return searcher --266
end--267
local function create_require ( env ) --270
env . package = env . package or { } --271
env . package . searchers = { return_lua_searcher ( env ) } --272
env . package . preload = { } --273
env . package . loaded = { } --274
env . package . path = sandboxes . _default_require_path --275
env . require = function ( modname ) --277
if env . package . loaded [ modname ] then --278
return env . package . loaded [ modname ] --279
end--280
local loader --282
local errors = { } --283
if env . package . preload [ modname ] then --284
loader = env . package . preload [ modname ] --285
else--286
for _ , searcher in _ENV.ipairs ( env . package . searchers ) do --287
local result = searcher ( modname ) --288
if _ENV.type ( result ) == "function" then --289
loader = result --290
break--291
else--292
_ENV.table . insert ( errors , result ) --293
end--294
end--295
end--296
if loader == nil then --297
_ENV.error ( _ENV.table . concat ( errors ) ) --298
else--299
local status , res = _ENV.pcall ( loader , modname ) --300
if status == false or _ENV.type ( res ) ~= "function" then --301
_ENV.error ( res , 2 ) --302
end--303
local chunk = res --305
status , res = _ENV.pcall ( chunk , modname ) --306
if status == false then --307
_ENV.error ( "error loading module '" .. modname .. "'\n" .. res , 2 ) --308
end--309
if res == nil then --310
res = true --311
end--312
env . package . loaded [ modname ] = res --313
return res --314
end--315
end--316
end--317
local string_metatable = _ENV.getmetatable ( "" ) --319
sandboxes . protected = sandboxes . clone ( sandboxes . restricted ) --321
sandboxes . protected . keeps : add ( "setmetatable" , "rawset" , "rawget" , "rawlen" , "rawequal" , "string.dump" , --322
"string.rep" , "collectgarbage" ) --323
sandboxes . protected . sets . getmetatable = function ( obj ) --324
if _ENV.type ( obj ) == "table" then --325
return _ENV.getmetatable ( obj ) --326
else--327
_ENV.error ( "attempt to get dangerous metatable from inside sandbox" , 2 ) --328
end--329
end--330
sandboxes . protected . special = function ( sbox ) --331
if _ENV._VERSION == "Lua 5.1" then --332
sbox . load = function ( a , b ) --333
local chunk , err = _ENV.load ( a , b ) --334
if chunk then --335
_ENV.setfenv ( chunk , sbox ) --335
end --335
return chunk , err --336
end--337
sbox . loadfile = function ( a ) --338
local chunk , err = _ENV.loadfile ( a ) --339
if chunk then --340
_ENV.setfenv ( chunk , sbox ) --340
end --340
return chunk , err --341
end--342
sbox . loadstring = function ( a ) --343
local chunk , err = _ENV.loadstring ( a ) --344
if chunk then --345
_ENV.setfenv ( chunk , sbox ) --345
end --345
return chunk , err --346
end--347
else--348
sbox . load = function ( a , b , c , env ) --349
if env == nil then --350
env = sbox --351
end--352
return _ENV.load ( a , b , c , env ) --353
end--354
sbox . loadfile = function ( a , b , env ) --355
if env == nil then --356
env = sbox --357
end--358
return _ENV.loadfile ( a , b , env ) --359
end--360
sbox . loadstring = function ( string , env ) --361
if env == nil then --362
env = sbox --363
end--364
return _ENV.load ( string , nil , "t" , env ) --365
end--366
end--367
sbox . dofile = function ( a ) --370
local chunk , err = sbox . loadfile ( a ) --371
if err then --372
_ENV.error ( err , 2 ) --372
end --372
return chunk ( ) --373
end--374
create_require ( sbox ) --375
end--376
return sandboxes --378
---