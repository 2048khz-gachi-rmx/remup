local uv, fs = require("uv"), require("fs")

require("./general.lua")

local ru = RemUp

if ru.Including then return end

local root = "libs/api/" -- needed for fs; not needed for require
local function recInc(path)
	for file, typ in fs.scandirSync(root .. path) do
		require("./" .. path .. file)
	end
end


ru.Including = true
	recInc("")
ru.Including = false