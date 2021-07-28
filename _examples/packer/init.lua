local readline = require("readline")

local fs = require("fs")
local path = require("path")

local ru = RemUp

local history = readline.History.new()
local editor = readline.Editor.new({stdin = process.stdin.handle, stdout = process.stdout.handle, history = history})

function WriteCompressedData(file_location, data, len)
	local file = ru.zip.GzOpen(file_location .. ".gz", "9w")
	ru.zip.GzWrite(file, data, len)
	ru.zip.GzClose(file)

	fs.unlinkSync(file_location)
end

function ProcessFolder(_, folder)
	if not fs.existsSync(folder) then print("Couldnt find folder", folder) return end

	for file, typ in fs.scandirSync(folder) do
		if(typ == "directory") then return end
		if file:match("%.gz$") then return end

		local file_location = path.join(folder, file)
		local data = fs.readFileSync(file_location)

		WriteCompressedData(file_location, data, #data)
	end
end

editor:readLine("Enter Folder: ", ProcessFolder)