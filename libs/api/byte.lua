local ru = RemUp or {}
ru.Bytes = {}

local byte = ru.Bytes

local function unsign(n)
	return n < 0 and bit.band(n, 0x7FFFFFFF) + 0x80000000 or n
end

function byte.ToUInt32LE(num)
	num = tonumber(num)

	return string.char(
		bit.band(bit.rshift(num, 0), 0xFF),
		bit.band(bit.rshift(num, 8), 0xFF),
		bit.band(bit.rshift(num, 16), 0xFF),
		bit.band(bit.rshift(num, 24), 0xFF)
	)
end

function byte.FromUInt32LE(bin)
	return unsign( bit.lshift(bin:sub(4, 4):byte(), 24) ) +
		bit.lshift(bin:sub(3, 3):byte(), 16) +
		bit.lshift(bin:sub(2, 2):byte(), 8) +
		bin:sub(1, 1):byte()
end

function byte.ToUInt32BE(num)
	num = tonumber(num)


	return string.char(
		bit.band(bit.rshift(num, 24), 0xFF),
		bit.band(bit.rshift(num, 16), 0xFF),
		bit.band(bit.rshift(num, 8), 0xFF),
		bit.band(num, 0xFF)
	)
end

function byte.FromUInt32BE(bin)
	return unsign( bit.lshift(bin:sub(1, 1):byte(), 24) ) +
		bit.lshift(bin:sub(2, 2):byte(), 16) +
		bit.lshift(bin:sub(3, 3):byte(), 8) +
		bin:sub(4, 4):byte()
end