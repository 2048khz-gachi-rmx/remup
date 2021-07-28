local ffi = require("ffi")

ffi.cdef[[
	unsigned long compressBound(unsigned long sourceLen);
	
	int compress2(uint8_t *dest, unsigned long *destLen,
		  const uint8_t *source, unsigned long sourceLen, int level);
	int uncompress(uint8_t *dest, unsigned long *destLen,
		   const uint8_t *source, unsigned long sourceLen);

	void* gzopen(const char* file_path, const char* mode);
	int gzwrite(void* file, const char* buffer, unsigned lenght);
	int gzclose(void* file);
]]

local bin = "./binaries/"
local zlib = ffi.load(ffi.os == "Windows" and bin .. "zlib.dll" or bin .. "zlib.so")

local ru = RemUp
ru.zip = {}
local zip = ru.zip

-- yoinked from ffi docs, too lazy
function zip.Compress(txt)
	local n = zlib.compressBound(#txt)
	local buf = ffi.new("uint8_t[?]", n)
	local buflen = ffi.new("unsigned long[1]", n)
	local res = zlib.compress2(buf, buflen, txt, #txt, 9)

	return ffi.string(buf, buflen[0])
end

function zip.Decompress(txt, len)
	local buf = ffi.new("uint8_t[?]", len)
  	local buflen = ffi.new("unsigned long[1]", len)
  	local res = zlib.uncompress(buf, buflen, txt, #txt)

  	return ffi.string(buf, buflen[0])
end

function zip.GzOpen(file_descriptor, mode)
	return zlib.gzopen(file_descriptor, mode)
end

function zip.GzWrite(gz_file, data, len)
	return zlib.gzwrite(gz_file, data, len)
end

function zip.GzClose(gz_file)
	return zlib.gzclose(gz_file)
end