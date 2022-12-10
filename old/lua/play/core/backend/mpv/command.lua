local socket = require("play.utils.pipe.socket")

---Create a command.
---@param name string Name of command.
---@param params any | any[] Parameters of this command.
---@param request_id? integer Request id. Default is 0.
---@param async? boolean When true, execute this command as async. Default is false.
---@return string
local function create_command(name, params, request_id, async)
    params = type(params) == "table" and params or { params } -- When params not table, change it to table.
    local command = {
        command = { name },
        request_id = request_id or 0,
        async = async or false,
    }
    for _, param in ipairs(params) do
        table.insert(command.command, param)
    end
    return vim.fn.json_encode(command) .. "\n"
end

---Execute mpv command asynchronously.
---@class MpvCommandExecutor
---@field socket SocketHandler Recieve message from mpv.
---@field path string Path to socket.
local M = {}

---Create a new MpvCommandExecutor instance.
---@param path string Path to socket.
---@return MpvCommandExecutor
function M:new(path)
    return setmetatable({
        socket = socket:new(),
        path   = path,
    }, {
        __index = self
    })
end

function M:execute(name, params, on_success)
    local id = math.floor(math.random(1e10))
    self.socket:connect(name)
    self.socket:write(create_command(name, params, id, false))
    self.socket:read_start(function(data)
        for d in data:gmatch("[^\n]+") do
            d = vim.fn.json_decode(d)
            if d.request_id == id then
                self.socket:read_stop()
                self.socket:disconnect()
                assert(d.success == "success", d.success)
                if on_success then
                    on_success(d)
                end
                return
            end
        end
    end)
end

return M
