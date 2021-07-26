local uv = require("uv")

-- narrator: he did not have luvit
_G.process = require("process").globalProcess()
_G.stdout = process.stdout
_G.stdin = process.stdin
_G.stderr = process.stderr

require("pretty-print")

_G.RemUp = {}

require("api/_init.lua")
require("app/list_actions.lua")
uv.run()

return {
    name = "remup",
    version = "0.0.1",
    private = true,
    dependencies = {}
}
