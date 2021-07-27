local ru = RemUp

local types = {
	["number"] = true,
	["string"] = true,
	["function"] = true,
	["table"] = true,
	["boolean"] = true,
	["bool"] = "boolean",
}

for k,v in pairs(types) do

	local desired = (v ~= true and v) or k

	_G["is" .. desired] = function(val)
		return type(val) == desired
	end

	_G["are" .. desired] = function(...)
		local len = select("#", ...)
		for i=1, len do
			if type(select(i, ...)) ~= desired then
				return false
			end
		end

		return true
	end
end

function coroutine.Wrapper(f)
	return function(...)
		local coro = coroutine.create(f)
		local ok, a, b, c, d, e, f = coroutine.resume(coro, ...)

		if not ok then
			error(a)
		end
		return a, b, c, d, e, f
	end
end

function table.Count(t)
	local c = 0
	for k,v in pairs(t) do
		c = c + 1
	end

	return c
end

function ru.SyncPrint(...)
	local str = ""
	local n = select("#", ...)
	for i=1, n do
		str = str .. tostring(select(i, ...)) .. (i ~= n and "	" or "")
	end

	io.write(str .. "\n")
end

function ru.ClearScreen()
	process.stdout:write("\x1b[H\x1b[2J")
end