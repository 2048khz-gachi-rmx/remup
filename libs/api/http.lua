local chttp = require("https")
local ClientRequest = require("http").ClientRequest
local buffer = require("./buffer")

local ru = RemUp
ru.http = {}
local http = ru.http

function http.Fetch(url, headers, body, options)
	-- everything past url is optional

	local obj
	obj = chttp.request(url, function(res)
		local size = 0
		local chunked = false

		obj.headers = res.headers

		for k,v in ipairs(res.headers) do
			local key = v[1]:lower()
			if key == "content-length" then
				size = tonumber(v[2])
			elseif key == "content-encoding" then
				chunked = true
			end
		end

		local buf = buffer:new((size and size + 1) or 1024)
		local cursor = 0

		res:on("data", function(dat)
			buf:writeData(cursor, dat)
			cursor = cursor + #dat
			obj.downloaded = cursor

			obj:emit("Data", dat)
		end)

		res:on("end", function()
			buf:writeData(cursor, "\0")
			obj:emit("Finish", buf)
		end)

		obj.todownload = size
		obj.chunked = chunked
	end)

	obj.downloaded = 0
	obj.todownload = 0
	obj.chunked = false

	return obj
end

function http.FetchMultiple(urls, simultaneous, headers, body)
	local ret = {}
	local queue = {}
	local amt = 0

	local function onEnd()
		local nm = queue[1]
		if not nm then return end

		table.remove(queue, 1)
		local req = ret[nm]
		req:on("Finish", onEnd)
		req:done()
	end

	for k,v in pairs(urls) do
		ret[k] = http.Fetch(v)

		if amt < simultaneous then
			amt = amt + 1

			ret[k]:on("Finish", onEnd)
			ret[k]:done()
		else
			queue[#queue + 1] = k
		end
	end

	return ret
end

function ClientRequest:GetDownloaded()
	return self.downloaded
end

function ClientRequest:GetToDownload()
	return self.todownload
end

function ClientRequest:GetPercent()
	if self:IsChunked() then return -1 end
	return self:GetDownloaded() / self:GetToDownload()
end

function ClientRequest:IsChunked()
	return self.chunked
end

function ClientRequest:IsHeaderReceived()
	return self.headers ~= nil
end

function ClientRequest:GetHeaders()
	return self.headers
end