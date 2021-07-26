local uv = require("uv")
local fs = require("fs")

-- why do *i* have to do these, luvit?
_G.process = require("process").globalProcess()
_G.stdout = process.stdout
_G.stdin = process.stdin
_G.stderr = process.stderr
--_G.p = require("pretty-print").prettyPrint
require("pretty-print")

_G.RemUp = {}

require("api/_init.lua")
require("app/list_actions.lua")

return {
    name = "remup",
    version = "0.0.1",
    private = true,
    dependencies = {}
}
