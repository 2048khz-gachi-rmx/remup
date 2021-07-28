local uv, fs = require("uv"), require("fs")

require("./general.lua")

local ru = RemUp
-- pray to god luvit require denies infinite looping ;)
-- if ru.Including then return end

local function recInc(root, path)
	-- root needed for fs; not needed for require

	for file, typ in fs.scandirSync(root .. path) do
		require("./" .. path .. file)
	end
end


function ru.RecursiveInclude(root, path)
	ru.Including = true
		recInc(root, path)
	ru.Including = false
end

ru.RecursiveInclude("libs/api/", "")