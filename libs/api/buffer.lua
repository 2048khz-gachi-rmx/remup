-- the shrigma buffer
local Buffer = require("buffer").Buffer
local ffi = require("ffi")

ffi.cdef[[
	void *malloc (size_t __size);
	void free (void *__ptr);
	void *realloc(void* ptr, size_t size);
]]

local C = ffi.os == "Windows" and ffi.load("msvcrt") or ffi.C

function Buffer:initialize(length)
	if type(length) == "number" then
		self.length = length
		self.datalen = 0

		self.ctype = ffi.gc(ffi.cast("unsigned char*", C.malloc(length)), C.free)
	elseif type(length) == "string" then
		local str = length

		self.length = #str
		self.datalen = #str

		self.ctype = ffi.gc(ffi.cast("unsigned char*", C.malloc(self.length)), C.free)
		ffi.copy(self.ctype, str, self.length)
	else
		error("Input must be a string or number")
	end
end

function Buffer.meta:__ipairs()
  local index = 0
  return function ()
    if index < self.datalen then
      index = index + 1
      return index, self[index]
    end
  end
end

function Buffer.meta:__tostring()
  return ffi.string(self.ctype, self.datalen)
end

local function po2(n)
	return bit.lshift(1, math.ceil(math.log(n + 1, 2)))
end

function Buffer:realloc(size)
	ffi.gc(self.ctype, nil) -- remove the finalizer from the old data, then realloc
	self.ctype = ffi.gc(ffi.cast("unsigned char*", C.realloc(self.ctype, size)), C.free)
	self.length = size
end

function Buffer:fit(amt)
	local newLen = po2(amt)
	if self.length < newLen then
		self:realloc(newLen)
	end
end

function Buffer:writeString(off, str)
	self:fit(off + #str)

	-- writes a *null-terminated* string
	ffi.copy(self.ctype + off, str)
	self.datalen = math.max(self.datalen, off + #str) -- pray for no 1-off errors
end

function Buffer:writeData(off, str)
	self:fit(off + #str)

	-- writes a string without a null terminator
	ffi.copy(self.ctype + off, str, #str)
	self.datalen = math.max(self.datalen, off + #str)
end

return Buffer