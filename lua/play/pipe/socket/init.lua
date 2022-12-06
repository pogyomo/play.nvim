local wrap = vim.schedule_wrap
local pipe = require("play.pipe")

---An class that handle connection to unix domain socket.
---@class SocketHandler
---@field pipe PipeHander Pipe handler.
local M = {}

---Create a new socket handler instance.
---@return SocketHandler
function M:new()
    return setmetatable({
        pipe = pipe:new(),
    }, {
        __index = self
    })
end

---Establish connection to unix domain socket.
---@param name string Path to unix domain socket.
function M:connect(name)
    if self.pipe:is_opened() then
        return
    end

    self.pipe:open()
    self.pipe:take():connect(name, wrap(function(err)
        if err then
            self.pipe:close()
            error(err)
        end
    end))
end

---Disconnect from the socket.
function M:disconnect()
    self.pipe:close()
end

---Write date to the socket.
---@param data string Data to be written.
function M:write(data)
    self.pipe:take():write(data, function(err)
        assert(not err, err)
    end)
end

---Start to read data.
---@param callback fun(data: string) Called when data was recieved.
function M:read_start(callback)
    self.pipe:take():read_start(wrap(function(err, data)
        assert(not err, err)
        if data then
            callback(data)
        else
            self:read_stop()
        end
    end))
end

---Stop to read data.
function M:read_stop()
    self.pipe:take():read_stop()
end

return M
