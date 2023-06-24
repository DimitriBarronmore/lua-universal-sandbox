
sandboxes = require("sandbox")

---[[ TESTING AREA ]]---

function test_print(env)
	for k,v in pairs(env) do
		if k ~= "_G" then
			if type(v) == "table" then
				-- print("same as default: ", v == _G[k])
				local concat = {}
				for j, l in pairs(v) do
					if type(l) == "table" then
						-- print("same as default: ", l == _G[k][j])
					end
					-- print ("%s.%s : %s":format(k, j, l))
					table.insert(concat, ("%s.%s"):format(k,j))
				end
				print(table.concat(concat, "    "))
			else
				print(("%s - %s"):format(k, v))
			end
		end
	end
end

-- local env = sandboxes.restricted:create_env()
-- local env2 = sandboxes.protected:create_env()

-- local templ2 = sandboxes.clone(sandboxes.restricted)
-- templ2.keeps:remove("print", "unpack")
-- local env2 = templ2:create_env()

-- test_print(env)
-- print("=====================")
-- test_print(env2)

-- tab = templ:create_env()

print "----[[ file loading protection test ]]----"

environment = sandboxes.protected:create_env()

local test_code = [[

	apple = "yummy"
	pear = "fruity"
	lemon = "sour"

	load("print(apple)")()
	
	loadstring("print(pear)")()
	
	loadfile("tmp_test.lua")()

	print(apple)

	dofile("tmp_test.lua")

	print(require("tmp_test-require"))


]]


environment.loadstring(test_code)()
-- chunk = loadstring(test_code)
-- setfenv(chunk, environment)
-- chunk()
print("post-test:", apple, pear, lemon)

-- -- print(getmetatable(""))
