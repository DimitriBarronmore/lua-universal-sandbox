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
"string.lower" , "string.upper" , "string.dump" , "string.find" , --203
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
sandboxes . protected = sandboxes . clone ( sandboxes . restricted ) --316
sandboxes . protected . special = function ( sbox ) --317
if _ENV._VERSION == "Lua 5.1" then --318
sbox . load = function ( a , b ) --319
local chunk , err = _ENV.load ( a , b ) --320
if chunk then --321
_ENV.setfenv ( chunk , sbox ) --321
end --321
return chunk , err --322
end--323
sbox . loadfile = function ( a ) --324
local chunk , err = _ENV.loadfile ( a ) --325
if chunk then --326
_ENV.setfenv ( chunk , sbox ) --326
end --326
return chunk , err --327
end--328
sbox . loadstring = function ( a ) --329
local chunk , err = _ENV.loadstring ( a ) --330
if chunk then --331
_ENV.setfenv ( chunk , sbox ) --331
end --331
return chunk , err --332
end--333
else--334
sbox . load = function ( a , b , c , env ) --335
if env == nil then --336
env = sbox --337
end--338
return _ENV.load ( a , b , c , env ) --339
end--340
sbox . loadfile = function ( a , b , env ) --341
if env == nil then --342
env = sbox --343
end--344
return _ENV.loadfile ( a , b , env ) --345
end--346
sbox . loadstring = function ( string , env ) --347
if env == nil then --348
env = sbox --349
end--350
return _ENV.load ( string , nil , "t" , env ) --351
end--352
end--353
sbox . dofile = function ( a ) --356
local chunk , err = sbox . loadfile ( a ) --357
if err then --358
_ENV.error ( err , 2 ) --358
end --358
return chunk ( ) --359
end--360
create_require ( sbox ) --361
end--362
local function test_print ( env ) --366
for k , v in _ENV.pairs ( env ) do --367
if k ~= "_G" then --368
if _ENV.type ( v ) == "table" then --369
local concat = { } --371
for j , l in _ENV.pairs ( v ) do --372
if _ENV.type ( l ) == "table" then --373
end--375
_ENV.table . insert ( concat , ( "%s.%s" ) : format ( k , j ) ) --377
end--378
_ENV.print ( _ENV.table . concat ( concat , "    " ) ) --379
else--380
_ENV.print ( ( "%s - %s" ) : format ( k , v ) ) --381
end--382
end--383
end--384
end--385
local environment = sandboxes . protected : create_env ( ) --406
local test_code = [[ 	apple = "yummy" 	pear = "fruity" 	lemon = "sour" 	load("print(apple)")() 	 	loadstring("print(pear)")() 	 	loadfile("tmp_test.lua")() 	print(apple) 	dofile("tmp_test.lua") 	print(require("tmp_test-require")) ]] --408
environment . loadstring ( test_code ) ( ) --429
_ENV.print ( _ENV.apple , _ENV.pear , _ENV.lemon ) --430
---