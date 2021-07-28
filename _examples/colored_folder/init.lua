local ru = RemUp

local url = "https://i.imgur.com/YvNitlv.png"

local ftch = ru.HTTP.Fetch(url, function(...)
	print("success", ...)
end)

ftch:on("Finish", function(buf)
	print("Buf done", buf.length)
end)

ftch:done()