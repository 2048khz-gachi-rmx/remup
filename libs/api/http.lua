local chttp = require("https")

local ru = RemUp
ru.HTTP = {}
local http = ru.HTTP

function http.Fetch(url, success, fail, headers, body, options)
	-- everything past url is optional
	return chttp.request(url, function(res)
		local sz = 0
		for k,v in ipairs(res.headers) do
			if k[1]:lower() == "content-length"
		print("connected", res.statusCode)
		p(res.headers)

		res:on("data", function(dat)
			print("data:", #dat)
		end)

		res:on("end", function(dat)
			print("ended:", dat)
		end)
	end)

	
end