local window = require("handle.window")
local buffer = require("handle.buffer")

---@class Window
---@field window WindowHandle
---@field buffer BufferHandle
local M = {}

---Create new window instance.
function M:new()
    return setmetatable({
        window = window:new(),
        buffer = buffer:new(),
    }, {
        __index = self
    })
end

---Initialize this window.
---@param enter boolean
---@param config table
function M:init(enter, config)
    self:close()
    self.buffer:init(false, true)
    self.window:init(self.buffer.handle, enter, config)
end

---Close this window.
function M:close()
    self.window:close()
    self.buffer:delete()
end

return M
