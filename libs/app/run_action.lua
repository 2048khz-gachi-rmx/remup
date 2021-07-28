local ru = RemUp
local path = require("path")

local function execute(what)
	for k,v in ipairs(ru.Actions) do
		if v.IsFolder then
			local fullPath = path.dirname(v.Path)
			local lastFolder = fullPath:match("[^" .. path.getSep() .. "]+$")

			if lastFolder == what then
				ru.ExecuteAction(v)
				return true
			end
		else
			if path.basename(v.Path, ".lua") == what then
				ru.ExecuteAction(v)
				return true
			end
		end
	end

	return false
end

ru.ExecuteActionByName = execute