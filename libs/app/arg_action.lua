require("app/find_actions.lua")
--require("app/run_action.lua")

local ru = RemUp
ru.Args = {}

local args = process.argv

local argStart = RemUp.ViaRepl and 2 or 1
local script = nil

for i=argStart, #args do
	local arg = args[i]
	if not script then
		script = arg
	else
		ru.Args[#ru.Args + 1] = arg
	end
end

local found

if script then
	found = ru.ExecuteActionByName(script)
	if not found then
		ru.SyncPrint(ru.ConStyle.FormatColor("red", "Couldn't find action `%s`.", script))
	end
end

if not found then
	-- no script selected; show a list
	require("app/list_actions.lua")
end

