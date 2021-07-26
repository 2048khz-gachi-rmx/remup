local ffi = require("ffi")

-- basic c file handling
-- i need it for zlib* functions that require a file pointer

ffi.cdef[[
	void* fopen(const char* file_name, const char* file_permissions);
	int fclose(void* file_pointer);
	int _fileno(void* file_pointer);
]]

local C = ffi.os == "Windows" and ffi.load("msvcrt") or ffi.C

local ru = RemUp
ru.cfile = {}
local cfile = ru.cfile

function cfile.Open(file, file_rights)
	return C.fopen(file, file_rights)
end

function cfile.Close(file)
	return C.fclose(file)
end


function cfile.FileDescriptor(file)
	return C._fileno(file)
end