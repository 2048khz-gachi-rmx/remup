local ffi = require("ffi")

ffi.cdef[[
	unsigned long compressBound(unsigned long sourceLen);
	
	int compress2(uint8_t *dest, unsigned long *destLen,
		  const uint8_t *source, unsigned long sourceLen, int level);
	int uncompress(uint8_t *dest, unsigned long *destLen,
		   const uint8_t *source, unsigned long sourceLen);
]]

local bin = "./binaries/"
local zlib = ffi.load(ffi.os == "Windows" and bin .. "zlib.dll" or bin .. "zlib.so")

local ru = RemUp
ru.Zip = {}
local Zip = ru.Zip

-- yoinked from ffi docs, too lazy
function Zip.Compress(txt)
	local n = zlib.compressBound(#txt)
	local buf = ffi.new("uint8_t[?]", n)
	local buflen = ffi.new("unsigned long[1]", n)
	local res = zlib.compress2(buf, buflen, txt, #txt, 9)
	return ffi.string(buf, buflen[0])
end

function Zip.Decompress(txt, len)
	local buf = ffi.new("uint8_t[?]", len)
  	local buflen = ffi.new("unsigned long[1]", len)
  	local res = zlib.uncompress(buf, buflen, txt, #txt)
  	return ffi.string(buf, buflen[0])
end