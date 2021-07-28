local ru = RemUp
local uv = require("uv")
local utils = require("utils")

ru.ConStyle = {}
local cc = ru.ConStyle

local function toCol(col, str)
	if utils.theme[col] then
		return utils.colorize(col, str)
	end

	return str
end

function cc.Color(col, ...)
	local str = ""
	local va = {...}

	for k, v in ipairs(va) do
		str = str .. tostring(v) .. (va[k + 1] and "	" or "")
	end

	return toCol(col, str)
end

function cc.FormatColor(col, fmt, ...)
	return toCol(col, fmt:format(...))
end

--[[
	cdata
	table
	number
	braces
	function
	quotes
	escape
	nil
	property
	failure
	highlight
	err
	boolean
	success
	string
	userdata
	thread
	sep
]]

local th = utils.theme

local function addcol(nm, c)
	th[nm] = c
end

addcol("red", "1;31")
addcol("yellow", "0;33")
addcol("green", "0;32")

addcol("blue", "0;34")
addcol("sky", "1;34")
addcol("cyan", "1;36")
addcol("purple", "0;35")
addcol("magenta", "1;35")

addcol("black", "1;30")
addcol("white", "0;37")


