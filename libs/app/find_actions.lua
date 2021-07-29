local fs = require("fs")
local path = require("path")

local ru = RemUp
local cs = ru.ConStyle

ru.Actions = {}
ru.FailedActions = {}

local function makeAction(fn_path, is_folder)
	local sep = path.getSep()
	local name = is_folder and fn_path:match("([^" .. sep .. "]+)" .. sep .. "init%.lua$") or
		fn_path:match("[^" .. sep .. "]+%.lua$")

	local action = {
		Path = fn_path,			-- path to the script
		IsFolder = is_folder,	-- boolean
		Name = name,			-- display name
		Description = cs.FormatColor("braces", "[no description provided]")
	}

	return action
end

local dirpath = os.getenv("REMUP")

if not dirpath then
	if jit.os == "Linux" then
		dirpath = os.getenv("HOME") .. "/RemUp"
	elseif jit.os == "Windows" then
		dirpath = path.getRoot() .. "RemUp"
	end
end

if not dirpath then
	print(cs.Color("red", "Failed to find a proper directory for RemUp.\n" ..
		"Try setting a REMUP env variable or using a proper OS, lol"))
	return
end

local list_exists = fs.existsSync(dirpath)

ru.DirPath = dirpath

if not list_exists then
	fs.mkdirSync(dirpath)
end

for file, typ in fs.scandirSync(dirpath) do
	local initter = path.join(dirpath, file)

	if typ == "file" then
		if file:match("%.lua$") then
			table.insert(ru.Actions, makeAction(initter, false))
		end
	else
		initter = path.join(initter, "init.lua")

		if not fs.existsSync(initter) then
			table.insert(ru.FailedActions, makeAction(path.join(dirpath, file), true))
		else
			local action = makeAction(initter, true)
			table.insert(ru.Actions, action)
		end
	end
end

function ru.ExecuteAction(act)
	local slashes = 2
	local action = "Running action:"
	local tx = ("%s %s %s %s"):format(
		("/"):rep(slashes),
		action, act.Name,
		("\\"):rep(slashes)
	)
	-- +1 : space after the slash
	local len = slashes + 1 + #action + #(act.UncoloredName or act.Name)

	ru.SyncPrint(cs.Color("nil", (" "):rep(slashes) .. ("_"):rep(len)))
	ru.SyncPrint(cs.Color("nil", tx .. "\n"))

	ru.CurrentAction = act.Path

	local resumer = coroutine.wrap(require)
	ru.ResumeAction = function(...)
		resumer(...)
	end

	resumer(act.Path)
end