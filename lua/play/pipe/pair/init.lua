local pipe = require("play.pipe")
local rwfd = require("play.pipe.pair.rwfd")
local wrap = vim.schedule_wrap

---A handler for a pair of connected pipe.
---This will be useful to communicate asynchronously.
---@class PairPipeHandler
---@field rwfd  RWFileDescriptorHandler File descriptors
---@field pipes { read: PipeHander, write: PipeHander }
local M = {}

---Create a new PairPipeHandler instance.
---@return PairPipeHandler
function M:new()
    return setmetatable({
        rwfd  = rwfd:new(),
        pipes = {
            read  = pipe:new(),
            write = pipe:new(),
        }
    }, {
        __index = self
    })
end

---Create a connection of pipes.
function M:create()
    self.rwfd:create()
    self.pipes.read:open()
    self.pipes.read:take():open(self.rwfd:take_read())
    self.pipes.write:open()
    self.pipes.write:take():open(self.rwfd:take_write())
end

---Write a data for read.
---@param data string Data to write.
function M:write(data)
    self.pipes.write:take():write(data, function(err)
        assert(not err, err)
    end)
end

---Start to read data.
---@param callback fun(data: string) Called when reader recieved data.
function M:read_start(callback)
    self.pipes.read:take():read_start(wrap(function(err, data)
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
    self.pipes.read:take():read_stop()
end

return M
