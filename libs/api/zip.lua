local fs = require("fs")
local buffer = require("./buffer")
local ffi = require("ffi")

ffi.cdef[[
	// func ptrs
	typedef void* (*alloc_func)(void* opaque, unsigned int items, unsigned int size);
	typedef void  (*free_func)(void* opaque, void* address);

	// structures
	typedef struct
	{
		unsigned have;
		unsigned char *next;
		int pos;
	} gzFile_s;

	// functions
	unsigned long compressBound(unsigned long sourceLen);

	int compress2(uint8_t *dest, unsigned long *destLen,
		  const uint8_t *source, unsigned long sourceLen, int level);
	int uncompress(uint8_t *dest, unsigned long *destLen,
		   const uint8_t *source, unsigned long sourceLen);

	gzFile_s* gzopen(const char* file_path, const char* mode);
	int gzwrite(gzFile_s* file, const char* buffer, unsigned length);
	int gzread(gzFile_s* file, const char* buffer, unsigned length);
	int gzclose(gzFile_s* file);
]]

local bin = "./binaries/"
local zlib = ffi.load(ffi.os == "Windows" and bin .. "zlib.dll" or bin .. "zlib.so")

local zip_extension = ".zp"

local ru = RemUp
ru.zip = {}
local zip = ru.zip

zip.Extension = zip_extension

-- yoinked from ffi docs, too lazy
function zip.Compress(txt)
	local size = tostring(#txt) .. txt

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

function zip.GzRead(gz_file, len)
	local buf = ffi.new("uint8_t[?]", len)
	local buflen = ffi.new("unsigned long[1]", len)
	local res = zlib.gzread(gz_file, buf, len)

	return ffi.string(buf, buflen[0])
end

function zip.GzClose(gz_file)
	return zlib.gzclose(gz_file)
end

function zip.CompressionBound(len)
	return zlib.compressBound(len)
end

function zip.CompressFile(file_name, new_fn)
	local file_data, err = fs.readFileSync(file_name)

	if not file_data then
		return false, err
	end

	if new_fn ~= false then
		local fd = fs.openSync(file_name .. zip_extension, "w")

		-- writes size and compressed data
		fs.writeSync(fd, 0, ru.Bytes.ToUInt32LE(#file_data))
		fs.writeSync(fd, 4, zip.Compress(file_data))

		fs.closeSync(fd)
		return true
	end

	return true, zip.Compress(file_data), #file_data
end

function zip.DecompressFile(file_name, new_fn)
	local fd, err = fs.openSync(file_name, "r")

	if not fd then
		return false, err
	end

	-- get data from file first
	local byte = fs.readSync(fd, 4, 0)
	local size = ru.Bytes.FromUInt32LE(byte)
	local compressed_size = zip.CompressionBound(size) -- calcs the compressed size from original
	local compressed_data = fs.readSync(fd, compressed_size, 4)
	fs.closeSync(fd)

	-- decompress
	local decompressed_data = zip.Decompress(compressed_data, size)

	-- write to new file or return the decompressed data
	if new_fn ~= false then
		-- write the decompressed
		local new_file_path = file_name:gsub(zip_extension:PatternSafe() .. "$", "")
		fs.writeFileSync(new_file_path, decompressed_data)
		return true
	else
		return true, decompressed_data
	end
end