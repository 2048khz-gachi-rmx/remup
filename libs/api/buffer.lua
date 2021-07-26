-- the shrigma buffer
local Buffer = require("buffer")
local ffi = require("ffi")

ffi.cdef[[
	void *malloc(size_t sz);
	void *realloc(void*ptr, size_t size);
	void free(void *ptr);
]]

function Buffer:realloc(size)
	C.realloc(self.ctype, size)
	self.length = size
end

function Buffer:writeString(off, str)
	-- writes a *null-terminated* string.
	ffi.copy(self.ctype + off, str)
end

function Buffer:writeData(off, str)
	-- writes string without a null terminator
	ffi.copy(self.ctype + off, str, #str)
end