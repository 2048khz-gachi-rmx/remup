local uv = require("uv")
local fs = require("fs")
local path = require("path")
local readline = require("readline")
local json = require("json")

local ru = RemUp

--[==================================[
	Action predefinitions
--]==================================]

local LoadActions
local DisplayActions
local DescribeAction
local ExecuteAction
--[==================================[
	Loading actions list
--]==================================]

local dirpath = path.getRoot() .. "RemUp"
local cs = ru.ConStyle

local list_exists = fs.existsSync(dirpath)

if not list_exists then
	fs.mkdirSync(dirpath)
end

local actions = {}

local function output(...)
	print(...)
end


function LoadActions()
	local threwHissyFit = false
	local processing = 0
	-- amt of processing actions; can't display actions until all are processed
	-- processing currently only includes reading the info.json from action folders

	local function poll()
		if processing == 0 then
			if threwHissyFit then
				print("")
			end
			coroutine.wrap(DisplayActions)()
		end
	end

	local function makeAction(fn_path, is_folder)
		local sep = path.getSep()
		local name = is_folder and fn_path:match("([^" .. sep .. "]+)" .. sep .. "init%.lua$") or fn_path:match("[^" .. sep .. "]+%.lua$")

		return {
			Path = fn_path,
			IsFolder = is_folder,
			Name = name,
			Description = cs.FormatColor("braces", "[no description provided]")
		}
	end

	local function readDesc(act)
		processing = processing + 1
		return function(_, cont, _)
			processing = processing - 1
			local tbl = json.decode(cont) or {}

			if tbl.name then
				local col = "boolean"
				local colored = false
				local uncolored_name = tbl.name
				while tbl.name:match("%[color=[^%]]+%]") do
					col = tbl.name:match("%[color=([^%]]+)%]")
					tbl.name = tbl.name:gsub("%[color=([^%]]+)%](.+)", function(match, rest) return cs.Color(match, rest) end, 1)
					colored = true
				end

				uncolored_name = uncolored_name:gsub("%[color=[^%]]+%]", "")

				if not colored then
					tbl.name = cs.Color(col, tbl.name)
				end

				act.Name = tbl.name
				act.UncoloredName = uncolored_name
			end

			act.Description = tbl.description
			act.HasInfo = true

			poll()
		end
	end

	for file, typ in fs.scandirSync(dirpath) do
		if typ == "file" then
			if file:match("%.lua$") then
				local action = makeAction(file, false)
				table.insert(actions, action)
			end
		else
			local initter = path.join(dirpath, file, "init.lua")
			if not fs.existsSync(initter) then
				output(cs.FormatColor("braces", "No actions detected in: %s", path.join(dirpath, file)))
				threwHissyFit = true
			else
				local info = path.join(dirpath, file, "info.json")
				local action = makeAction(initter, true)
				if fs.existsSync(info) then
					fs.readFile(info, readDesc(action))
				end

				table.insert(actions, action)
			end
		end
	end
end

local function getAction(num)
	return actions[tonumber(num)]
end

--[==================================[
	Displaying actions
--]==================================]

local defaultPrompt = "> "
local history = readline.History.new()
local editor = readline.Editor.new({stdin = process.stdin.handle, stdout = process.stdout.handle, history = history})

local indent = (" "):rep(3)

local function readLine(prompt, cb)
	prompt = prompt or defaultPrompt
	editor:readLine(prompt, cb)
end

local i_will_allow_it = {"yes", "yeah", "ye", "ya", "y", "yea", "yis", "yee", "yuh"}

	for k,v in ipairs(i_will_allow_it) do
		i_will_allow_it[v] = true
		i_will_allow_it[k] = nil
	end



local function isYes(str, is_default)
	local yes = str:lower():match("^y%w*")
	if i_will_allow_it[yes] or (is_default and str == "") then
		return true
	else
		return false
	end
end

function editor:clearScreen()
	self.stdout:write('\x1b[H\x1b[2J')
	--self:refreshLine()
end

function DisplayActions()
	if #actions == 0 then
		output(cs.FormatColor("failure", "No actions detected. Make sure you have files in: %s", dirpath))
		return
	end

	editor:clearScreen()

	table.sort(actions, function(a, b)
		local folder_prio = a.IsFolder and not b.IsFolder
		if folder_prio then return folder_prio end

		local alpha_prio = a.Name < b.Name
		return alpha_prio
	end)


	output(cs.FormatColor("cdata", " %d actions found:", #actions))

	for k,v in ipairs(actions) do
		output(cs.FormatColor(v.IsFolder and "boolean" or "property", "%s%d: %s", indent, k, v.Name))
	end

	output(cs.FormatColor("thread", "\n%sq: Exit.\n", indent))

	local onInput

	-- lulz
	
	local function thereIsNoSpoon(num)
		output(cs.FormatColor("failure", "No action with the index `%s`.", num))
		readLine(nil, onInput)
	end

	function onInput(_, str, _)
		if not str or str == "q" then os.exit() return end

		local match = str:match("^%d+")
		if match and match ~= str then
			local num = tonumber(match)
			if not getAction(num) then
				thereIsNoSpoon(num)
				return
			end

			-- lazy match?
			output(cs.FormatColor("boolean", "Did you mean `%s` ?", match))
			DescribeAction(getAction(num))
			return
		end

		local num = tonumber(match) -- no dumb shit like 1e9 or -15
		if not num then
			output(cs.FormatColor("failure", "...that's not a number bru"))
			readLine(nil, onInput)
			return
		end

		if not getAction(num) then
			thereIsNoSpoon(num)
			return
		end

		DescribeAction(getAction(num))
	end

	readLine(nil, onInput)
end


LoadActions()

--[[
	Describing Action
]]

function DescribeAction(act)
	output()
	output(indent .. act.Name)
	output(indent .. cs.Color("nil", " - " .. act.Description))
	output()
	output(cs.Color("cyan", indent .. "Execute? [Y/n]"))

	local function onInput(_, str)
		if not str then return end
		if not isYes(str, true) then
			DisplayActions()
			return
		end


		ExecuteAction(act)
	end

	readLine(nil, onInput)
end

--[[
	Executing Action
]]

function ExecuteAction(act)
	output(cs.Color("nil", "________________________\n"))
	local ok, err = coroutine.wrap(require)(act.Path)
end