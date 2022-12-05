local uv   = vim.loop
local wrap = vim.schedule_wrap

---Handle the connection to unix domain socket.
---@class Socket
---@field pipe userdata | nil A instance which new_pipe return.
local M = {}

---Create a new Socket instance
---@return Socket
function M:new()
    return setmetatable({
        pipe = nil,
    }, {
        __index = self
    })
end

---Check whether connection is established or not.
---@return boolean
function M:is_connected()
    return self.pipe ~= nil and self.pipe:getpeername()
end

---Connect to given unix domain socket.
---@param path string Path to the socket.
---@param callback fun(data: string)
function M:connect(path, callback)
    if self:is_connected() then
        error(string.format("Connection already established: %s", self.pipe:getpeername()))
    end

    self.pipe = uv.new_pipe()
    self.pipe:connect(path, wrap(function(err1)
        assert(not err1, err1)
        self.pipe:read_start(wrap(function(err2, data)
            assert(not err2, err2)
            callback(data)
        end))
    end))
end

---Disconnect from the unix domain socket.
function M:disconnect()
    if self:is_connected() then
        self.pipe:close()
        self.pipe = nil
    end
end

---Write given data to the socket.
---@param data string
function M:write(data)
    assert(self.pipe, "Connection isn't established.")
    self.pipe:write(data, function(err)
        assert(not err, err)
    end)
end

return M
