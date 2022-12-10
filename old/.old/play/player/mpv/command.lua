local socket = require("play.utils.pipe.socket")
local pair   = require("play.utils.pipe.pair")


---Create a command.
---@param name string Name of command.
---@param params any | any[] Parameters of this command.
---@param id integer Request id.
---@return string
local function create_command(name, params, id)
    params = type(params) == "table" and params or { params } -- When params not table, change it to table.
    local command = { command = { name }, request_id = id }
    for _, param in ipairs(params) do
        table.insert(command.command, param)
    end
    return vim.fn.json_encode(command) .. "\n"
end

---Execute mpv command asynchronously.
---@class MpvCommandExecutor
---@field socket SocketHandler Reciever message from mpv.
---@field pair PairPipeHandler Handle message asynchronously.
---@field path string Path to socket.
local M = {}

---Create a new MpvCommandExecutor instance.
---@param path string Path to socket.
---@return MpvCommandExecutor
function M:new(path)
    return setmetatable({
        socket = socket:new(),
        pair   = pair:new(),
        path   = path,
    }, {
        __index = self
    })
end

---Execute command.
---@param name string Name of command.
---@param params any | any[] Parameters of this command.
---@param on_success? fun(data: table) Called when command is executed successfully.
function M:execute(name, params, on_success)
    self.pair:connect()
    self.socket:connect(self.path)
    self.socket:read_start(function(data)
        self.pair:write(data)
    end)

    local id = math.floor(math.random(1e10)) -- Get a unique id.
    self.socket:write(create_command(name, params, id))
    self.pair:read_start(function(data)
        for d in data:gmatch("[^\n]+") do -- When a reply have multiple message, split it by newline.
            d = vim.fn.json_decode(d)
            if d.request_id == id then
                self.pair:disconnect()
                self.socket:disconnect()
                if d.error == "success" then
                    if on_success then
                        on_success(d)
                    end
                else
                    error(("Failed to execute command '%s': %s"):format(name, d.error))
                end
            end
        end
    end)
end

---Change property by using given value
---@generic T
---@param name string Name of the property.
---@param value T Value to set.
---@param on_success? fun(data: table) Called when command is executed successfully.
function M:change_property(name, value, on_success)
    self:execute("set_property", { name, value }, on_success)
end

---Change property changer.
---@generic T
---@param name string Name of the property.
---@param changer fun(property: T): T
---@param on_success? fun(data: table) Called when command is executed successfully.
function M:change_property_with(name, changer, on_success)
    self:execute("get_property", name, function(data)
        self:change_property(name, changer(data.data), on_success)
    end)
end

return M
