local uv = require("uv")

local via_luvit = _G.process ~= nil

-- narrator: he did not have luvit
_G.process = require("process").globalProcess()
_G.stdout = process.stdout
_G.stdin = process.stdin
_G.stderr = process.stderr

require("pretty-print")

_G.RemUp = {}
RemUp.Flags = {}
RemUp.ViaRepl = via_luvit

local miniz = require("miniz")
p(miniz)



require("api/_init.lua")

RemUp.zip.CompressAsync( ("peepee funnie"):rep(10000) )
do return end

RemUp.ClearScreen()
require("app/arg_action.lua")

uv.run()

return {
    name = "remup",
    version = "0.0.1",
    private = true,
    dependencies = {}
}
