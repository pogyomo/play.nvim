local job    = require("play.job")
local socket = require("play.pipe.socket")
local pair   = require("play.pipe.pair")
local socket_path = "/tmp/mpvsocket"

---Create a command.
---@param name string Name of command.
---@param params any | any[] Parameters of this command.
---@param id integer Request id.
---@return string
local function create_command(name, params, id)
    params = type(params) == "table" and params or { params }
    local command = { command = { name }, request_id = id }
    for _, param in ipairs(params) do
        table.insert(command.command, param)
    end
    return vim.fn.json_encode(command) .. "\n"
end

---A simple handler of mpv.
---@class MpvHandler
---@field mpv_job JobHandler JobHandler to handle mpv.
---@field socket SocketHandler Socket to communicate with mpv.
---@field pair PairPipeHandler PairPipe to treat reply which mpv send.
local M = {}

---Create a new MpvHandler instance.
---@return MpvHandler
function M:new()
    return setmetatable({
        mpv_job = job:new(),
        socket  = socket:new(),
        pair    = pair:new()
    }, {
        __index = self
    })
end

---Play given file without video (only sound).
---@param path string
function M:start_file_without_video(path)
    self.mpv_job:start("mpv", {
        "--input-ipc-server=" .. socket_path,
        "--no-video",
        "--no-terminal",
        path,
    })
    self.pair:connect()
    vim.defer_fn(function()
        self.socket:connect(socket_path)
        self.socket:read_start(function(data)
            self.pair:write(data)
        end)
    end, 1000)
end

---Stop playback and exit from mpv.
function M:stop()
    self.pair:disconnect()
    self.socket:disconnect()
    self.mpv_job:stop()
end

---Load file from given path/url.
---@param path string Path or url to load.
function M:loadfile(path)
    self:exec_command("loadfile", vim.fn.expand(path))
end

---Seek playback time by given diff.
---@param diff integer
function M:seek(diff)
    self:exec_command("seek", diff)
end

---Pause the playback.
function M:pause()
    self:change_property("pause", true)
end

---Resume the playback.
function M:resume()
    self:change_property("pause", false)
end

---Toggle pause and resume.
function M:toggle()
    self:change_property_by_using_curent("pause", function(property)
        return not property
    end)
end

---Increase/Decrease the volume by given diff.
---@param diff integer How much to change volume.
function M:volume(diff)
    self:change_property_by_using_curent("volume", function(property)
        return property + diff
    end)
end


---Execute command.
---@param name string Name of command.
---@param params any | any[] Parameters of this command.
---@param on_success? fun(data: table) Called when command is executed successfully.
function M:exec_command(name, params, on_success)
    local id = math.floor(math.random(1e10)) -- Get a unique id.
    self.socket:write(create_command(name, params, id))
    self.pair:read_start(function(data)
        for d in data:gmatch("[^\n]+") do -- When a reply have multiple message, split it by newline.
            d = vim.fn.json_decode(d)
            if d.error ~= "success" and d.request_id == id then
                self.pair:read_stop()
                error(("Failed to execute command '%s': %s"):format(name, d.error))
            elseif d.error == "success" and d.request_id == id then
                self.pair:read_stop()
                if on_success then
                    on_success(d)
                end
            end
        end
    end)
end

---Change property by using given value
---@generic T
---@param name string Name of the property.
---@param value T Value to set.
function M:change_property(name, value)
    self:exec_command("set_property", { name, value })
end

---Change property by using current property.
---@generic T
---@param name string Name of the property.
---@param changer fun(property: T): T
function M:change_property_by_using_curent(name, changer)
    self:exec_command("get_property", { name }, function(data)
        self:change_property(name, changer(data.data))
    end)
end

return M
