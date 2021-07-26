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