 local _ENV = _ENV if _VERSION < "Lua 5.2" then 	_ENV = (getfenv and getfenv()) or _G end		 --0
 local __export = {}  		 --0
----
local function copy_list ( module , whitelist ) --6
local out = { } --7
if whitelist then --8
for word in _ENV.string . gmatch ( whitelist , "%a+" ) do --9
out [ word ] = module [ word ] --10
end--11
else--12
for k , v in _ENV.pairs ( module ) do --13
out [ k ] = v --14
end--15
end--16
return out --17
end--18
local deepcopy --29
deepcopy = function ( o , seen ) --30
seen = seen or { } --31
if o == nil then --32
return nil end --32
if seen [ o ] then --33
return seen [ o ] end --33
local no --35
if _ENV.type ( o ) == 'table' then --36
no = { } --37
seen [ o ] = no --38
for k , v in _ENV.next , o , nil do --40
no [ deepcopy ( k , seen ) ] = deepcopy ( v , seen ) --41
end--42
_ENV.setmetatable ( no , deepcopy ( _ENV.getmetatable ( o ) , seen ) ) --43
else--44
no = o --45
end--46
return no --47
end--48
local initial_environment = { --52
_VERSION = _ENV._VERSION , --53
assert = _ENV.assert , --54
collectgarbage = _ENV.collectgarbage , --55
dofile = _ENV.dofile , --56
error = _ENV.error , --57
getmetatable = _ENV.getmetatable , --58
ipairs = _ENV.ipairs , --59
load = _ENV.load , --60
loadfile = _ENV.loadfile , --61
loadstring = _ENV.loadstring , --62
next = _ENV.next , --63
pairs = _ENV.pairs , --64
pcall = _ENV.pcall , --65
print = _ENV.print , --66
rawequal = _ENV.rawequal , --67
rawlen = _ENV.rawlen , --68
rawset = _ENV.rawset , --69
rawget = _ENV.rawget , --70
require = _ENV.require , --71
select = _ENV.select , --72
setmetatable = _ENV.setmetatable , --73
tonumber = _ENV.tonumber , --74
tostring = _ENV.tostring , --75
type = _ENV.type , --76
warn = _ENV.warn , --77
xpcall = _ENV.xpcall , --78
unpack = _ENV.unpack , --79
getfenv = _ENV.getfenv , --80
setfenv = _ENV.setfenv , --81
utf8 = deepcopy ( _ENV.utf8 ) , --82
coroutine = deepcopy ( _ENV.coroutine ) , --83
debug = deepcopy ( _ENV.debug ) , --84
io = deepcopy ( _ENV.io ) , --85
math = deepcopy ( _ENV.math ) , --86
os = deepcopy ( _ENV.os ) , --87
string = deepcopy ( _ENV.string ) , --88
package = deepcopy ( _ENV.package ) , --89
table = deepcopy ( _ENV.table ) , --90
}--91
local set_mt = { } --94
set_mt . __index = set_mt --95
function set_mt : add ( ... ) --96
for _ , element in _ENV.ipairs ( { ... } ) do --97
self [ element ] = true --98
end--99
end--100
function set_mt : remove ( ... ) --101
for _ , element in _ENV.ipairs ( { ... } ) do --102
self [ element ] = nil --103
end--104
end--105
function set_mt : removeall ( ) --106
for key in _ENV.pairs ( self ) do --107
self [ key ] = nil --108
end--109
end--110
function set_mt : add_from_table ( tab ) --111
for key in _ENV.pairs ( tab ) do --112
self [ key ] = true --113
end--114
end--115
local function new_set ( ) --117
return _ENV.setmetatable ( { } , set_mt ) --118
end--119
local template_mt = { } --127
template_mt . __index = template_mt --128
function template_mt : create_env ( ) --131
local environment = { } --132
if self . inherits then --133
local old_environment = self . inherits : create_env ( ) --134
for key in _ENV.pairs ( self . keeps ) do --135
local module , method = key : match ( '([^%.]+)%.([^%.]+)' ) --136
if module and old_environment [ module ] then --137
environment [ module ] = environment [ module ] or { } --138
environment [ module ] [ method ] = old_environment [ module ] [ method ] --139
else--140
environment [ key ] = old_environment [ key ] --141
end--142
end--146
old_environment = nil --147
end--150
for key , value in _ENV.pairs ( self . sets ) do --151
environment [ deepcopy ( key ) ] = deepcopy ( value ) --152
end--153
if self . special then --154
self . special ( environment ) --155
end--156
return environment --157
end--158
local sandboxes = { } --160
function sandboxes . clone ( original ) --163
local new = { } --164
new . __is_sandbox_template = true --165
new . keeps = new_set ( ) --166
new . sets = { } --167
new . inherits = original . inherits --168
for key in _ENV.pairs ( original . keeps ) do --169
new . keeps : add ( key ) --170
end--171
for key , value in _ENV.pairs ( original . sets ) do --172
new . sets [ key ] = value --173
end--174
new . special = original . special --175
new . _G = new --176
_ENV.setmetatable ( new , template_mt ) --177
return new --178
end--179
function sandboxes . new ( inherits , inherit_keeps ) --183
local new_template = { } --184
new_template . __is_sandbox_template = true --185
new_template . keeps = new_set ( ) --186
new_template . sets = { } --187
if inherits then --188
if inherits . __is_sandbox_template then --189
new_template . inherits = inherits --190
if inherit_keeps then --191
for key in _ENV.pairs ( inherits . keeps ) do --192
new_template . keeps : add ( key ) --193
end--194
end--195
else--196
_ENV.error ( "attempted to inherit from invalid parent" , 2 ) --197
end--198
end--199
new_template . _G = new_template --200
_ENV.setmetatable ( new_template , template_mt ) --201
return new_template --202
end--203
sandboxes . unsafe = sandboxes . new ( ) --205
sandboxes . unsafe . sets = initial_environment --206
sandboxes . restricted = sandboxes . new ( sandboxes . unsafe ) --210
sandboxes . restricted . keeps : add ( "_VERSION" , "assert" , "collectgarbage" , "error" , "ipairs" , "next" , --211
"pairs" , "pcall" , "print" , "select" , "tonumber" , "tostring" , "type" , --212
"warn" , "xpcall" , "unpack" , --213
"utf8.char" , "utf8.charpattern" , "utf8.codes" , "utf8.codepoint" , --214
"utf8.len" , "utf8.offset" , --215
"math.abs" , "math.acos" , "math.asin" , "math.atan" , "math.atan2" , --216
"math.ceil" , "math.floor" , "math.cos" , "math.cosh" , "math.deg" , --217
"math.exp" , "math.fmod" , "math.frexp" , "math.huge" , "math.ldexp" , --218
"math.log" , "math.log10" , "math.max" , "math.min" , "math.modf" , "math.pi" , --219
"math.pow" , "math.rad" , "math.random" , "math.sin" , "math.sinh" , --220
"math.sqrt" , "math.tan" , "math.tanh" , --221
"string.lower" , "string.upper" , "string.dump" , "string.find" , --222
"string.match" , "string.gmatch" , "string.gsub" , "string.format" , --223
"string.len" , "string.byte" , "string.char" , "string.sub" , "string.rep" , --224
"string.reverse" , --225
"coroutine.status" , "coroutine.running" , "coroutine.isyieldable" , --226
"coroutine.create" , "coroutine.yield" , "coroutine.resume" , --227
"coroutine.wrap" , --228
"os.clock" , "os.difftime" , "os.time" , --229
"table.insert" , "table.maxn" , "table.remove" , "table.sort" --230
)--231
sandboxes . protected = sandboxes . clone ( sandboxes . restricted ) --237
sandboxes . protected . special = function ( sbox ) --238
if _ENV._VERSION < 5.2 then --239
sbox . load = function ( a , b ) --240
local chunk , err = _ENV.load ( a , b ) --241
if chunk then --242
_ENV.setfenv ( chunk , sbox ) --242
end --242
return chunk , err --243
end--244
sbox . loadfile = function ( a ) --245
local chunk , err = _ENV.loadfile ( a ) --246
if chunk then --247
_ENV.setfenv ( chunk , sbox ) --247
end --247
return chunk , err --248
end--249
sbox . loadstring = function ( a ) --250
local chunk , err = _ENV.loadstring ( a ) --251
if chunk then --252
_ENV.setfenv ( chunk , sbox ) --252
end --252
return chunk , err --253
end--254
else--255
sbox . load = function ( a , b , c , env ) --256
if env == nil then --257
env = sbox --258
end--259
return _ENV.load ( a , b , c , env ) --260
end--261
sbox . loadfile = function ( a , b , env ) --262
if env == nil then --263
env = sbox --264
end--265
return _ENV.loadfile ( a , b , env ) --266
end--267
sbox . loadstring = function ( string , env ) --268
if env == nil then --269
env = sbox --270
end--271
return _ENV.load ( string , nil , "t" , env ) --272
end--273
end--274
sbox . dofile = function ( a ) --277
local chunk , err = sbox . loadfile ( a ) --278
if err then --279
_ENV.error ( err , 2 ) --279
end --279
return chunk ( ) --280
end--281
end--282
local function test_print ( env ) --286
for k , v in _ENV.pairs ( env ) do --287
if k ~= "_G" then --288
if _ENV.type ( v ) == "table" then --289
local concat = { } --291
for j , l in _ENV.pairs ( v ) do --292
if _ENV.type ( l ) == "table" then --293
end--295
_ENV.table . insert ( concat , ( "%s.%s" ) : format ( k , j ) ) --297
end--298
_ENV.print ( _ENV.table . concat ( concat , "    " ) ) --299
else--300
_ENV.print ( ( "%s - %s" ) : format ( k , v ) ) --301
end--302
end--303
end--304
end--305
---