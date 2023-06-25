# sandbox.lua

A library for the extensible creation of instanced sandboxes.

Ever find yourself in a situation where you want to:
- recreate the same sandbox over and over again? 
- create a basic sandbox for untrusted code without putting in any actual hard work?
- section off a chunk of code from some unruly stray variables?

If you answered "yes" to any of the above, this might be the library for you.

Note that this library does not help you run the code, it only creates sandboxed environments for you to run code in.


# Supported Lua Versions
In theory, this should work from Lua 5.1/JIT and above.

# Usage 
Require the module:
```lua
local sandboxes = require "sandbox"
```

The library comes with three sandboxes predefined:

- `sandboxes.restricted`:  A highly sanitized sandbox template based on https://github.com/kikito/lua-sandbox/ and https://lua-users.org/wiki/SandBoxes. Attempts to remove any functions that might have adverse effects if executed or which could be used to escape from the sandbox.
- `sandboxes.protected`: A significantly less strict template which attempts to remain escape-proof without sacrificing usability. All code/file loading functions are reimplemented to execute within the sandbox's environment, and `getmetatable` cannot be used on strings.
- `sandboxes.unsafe`: Absolutely no sanitization whatsoever, just a straight copy of the standard global environment at the time the library is loaded.

To get a usable sandboxed environment from a template:
```lua
-- Select whatever sandbox template you want to use.
my_sandbox = sandboxes.restricted:create_env()

-- You can now run code in the returned environment table however you see fit.
-- Note that all sandboxes created by this library are initialized with `._G` pointing to the sandbox itself.
loadfile("important_code.lua", nil, my_sandbox)
```

Several utilities are provided to allow you to expand the existing templates or create your own from scratch.

```lua
-- Create a blank sandbox template.
my_template = sandboxes.new()
-- Start your sandbox from an existing template.
my_template = sandboxes.new(parent_template)
-- Clone an existing template completely.
my_template = sandboxes.clone(original_template)

-- Items from the parent environment are filtered through a two-table-deep whitelist, which is implemented as a set.
my_template.keeps:add("func1", "func2", "module.func")
my_template.keeps:remove("func2")

-- To add items en-mass, you can add an entire key/value table and a single layer of sub-tables to the whitelist
-- all at once. This is best run on a parent template's `.sets` table, which allows you to then list items to remove
-- in the form of a blacklist.
my_template.keeps:add_from_table(table)

-- New items to be added to the sandbox are stored in a key/value array and deep-copied when the sandbox is created.
my_template.sets.my_function = function() dothing() end
my_template._sets.my_table = {"This table will be unique each time."}

-- Sometimes you might need to add something extra after the sandbox has been fully constructed,
-- such as functions or values that reference the sandbox itself. We have a callback for that.
my_template.special = function(sandbox)
    sandbox.recursion = sandbox
end
```

# Small Compatibility Notes:
The `protected` template's reimplementation of `require` works in base lua, but may not work in strange distributions that change `package.path` or restrict access to `io.open`. If this is the case, you can set `sandbox._default_require_path` to a new filepath and `sandbox._check_file_exists(filename)` to a function which takes a filename and returns `true` if that file exists.
