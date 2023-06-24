

---@param module table The base module being copied.
---@param whitelist string? An optional whitelist of module contents.
---@return table new_module The new copy of the given module.
---Makes a shallow copy of the given module. If a whitelist is provided,
---only the first-level contents of the whitelist are copied.
local function copy_list(module, whitelist)
	local out = {}
	if whitelist then
		for word in string.gmatch(whitelist, "%a+") do
			out[word] = module[word]
		end
	else
		for k,v in pairs(module) do
			out[k] = v
		end
	end
	return out
end

-- An extremely direct copy of _G.
-- Provides literally no protection, but keeps global values separate.
local fully_unprotected = {}
for k,v in pairs(_G) do
	fully_unprotected[k] = v
end
-- fully_unprotected._G = fully_unprotected

local protected = {
	_VERSION = _VERSION,
	assert = assert,
	error = error,
	ipairs = ipairs,
	next = next,
	pairs = pairs,
	pcall = pcall,
	print = print,
	rawequal = rawequal,
	rawlen = rawlen,
	select = select,
	tonumber = tonumber,
	tostring = tostring,
	type = type,
	utf8 = utf8,
	warn = warn,
	xpcall = xpcall,
	unpack = unpack,

	coroutine = copy_list(coroutine, "create resume running status wrap yield isyieldable"),
	math = copy_list(math),
	os = copy_list(os, "clock date difftime time"),
	table = copy_list(table),
	string = copy_list(string),
}

--[[
	collectgarbage = collectgarbage,
	dofile = dofile,
	getmetatable = getmetatable,
	load = load,
	loadfile = loadfile,
	rawget = rawget,
	rawset = rawset,
	require = require,
	setmetatable = setmetatable,

	-- io
	-- package
]]

---@class sandbox
---@field base_list table contains the basemost key/value pairs to copy
---@field _extends sandbox? another sandbox this one inherits from
---@field blacklist table? a set-style blacklist for inherited key/value pairs.
---exclusive with and superceeded by whitelist.
---@field whitelist table? a set-style whitelist for inherited key/value pairs.
---exclusive with and superceeds blacklist.
---@field post function? a function which runs after the sandbox is built. inherits down the chain.
local sandbox_mt = {}
sandbox_mt.__metatable = sandbox_mt
sandbox_mt.base_list = {}

local copy_into
---@param base table The table being copied into.
---@param input table The table being copied out of.
---@param mode "blacklist" | "whitelist" | nil The operation's filter mode.
---@param filter table? The filter set being used.
---@param prefix string? A prefix used for advanced blacklisting.
---Deep-copies a table's contents into another, existing table, respecting a black/whitelist filter.
---Sub-tables are expected to be non-recursive modules, and will not fully overwrite existing
---tables in the output of the same name. Blacklisting sub-table contents follows "mod.field" syntax.
function copy_into(base, input, mode, filter, prefix)
	filter = filter or {}
	prefix = prefix or ""
	for key, val in next, input, nil do
		local skip = false
		if (mode == "blacklist") and filter[prefix .. key] then
			skip = true
		elseif (mode == "whitelist") and (not filter[prefix .. key]) then
			skip = true
		end
		if not skip then
			if type(val) == table then
				if type(base[key]) ~= "table" then
					base[key] = {}
				end
				copy_into(base[key], val, mode, filter, prefix .. "key.")
			else
				base[key] = val
			end
		end
	end
end

---@return table env The new environment which was created.
---Creates a new environment table deep-copied from the given sandbox.
function sandbox_mt:new()
	local new_environment = {}

	-- assemble the chain of inheritance
	local chain = { self }
	local current = self
	repeat
		if current._extends then
			table.insert(chain, 1, current._extends)
			current = current._extends
		end
---@diagnostic disable-next-line: need-check-nil
	until current._extends == nil

	-- Begin copying items, one inherited whitelist at a time.
	-- for i, box in chain do
	for i = 1, #chain do
		---@type sandbox
		local box = chain[i]
		---@type sandbox
		local next_box = chain[i + 1]

		local mode, filter
		if next_box then
			if next_box.whitelist then
				mode = "whitelist"
				filter = next_box.whitelist
			elseif next_box.blacklist then
				mode = "blacklist"
				filter = next_box.blacklist
			end
		end
		copy_into(new_environment, box.base_list, mode, filter)

		-- Next, we get to run the current set's special setup method.
		if box.post then
			box.post(box)
		end
	end

	-- Once all that is done for the entire chain, we can return the created sandbox.
	return new_environment
end

function sandbox_mt:extend()
	---@type sandbox
	local new_sandbox = {}
	new_sandbox._extends = self
end