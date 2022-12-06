local job    = require("play.job")
local socket = require("play.pipe.socket")
local pair   = require("play.pipe.pair")

---Create a command with id.
---@param name string Name of command.
---@param id integer Request id.
---@param ... any Parameters of this command.
local function create_command(name, id, ...)
    return vim.fn.json_encode({ command = { name, ... }, request_id = id }) .. "\n"
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
        "--input-ipc-server=/tmp/mpvsocket",
        "--no-video",
        "--no-terminal",
        path,
    })
    self.pair:create()
    vim.defer_fn(function()
        self.socket:connect("/tmp/mpvsocket")
        self.socket:read_start(function(data)
            self.pair:write(data)
        end)
    end, 1000)
end

---Stop playback and exit from mpv.
function M:stop()
    self.socket:disconnect()
    self.mpv_job:stop()
end

---Load file from given path/url.
---@param path string Path or url to load.
function M:loadfile(path)
    self.socket:write(create_command("loadfile", vim.fn.expand(path)))
end

---Seek playback time by given diff.
---@param diff integer
function M:seek(diff)
    self.socket:write(create_command("seek", diff))
end

---Pause the playback.
function M:pause()
    self.socket:write(create_command("set_property", 0, "pause", true))
end

---Resume the playback.
function M:resume()
    self.socket:write(create_command("set_property", 0, "pause", false))
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

---Change property by using current property.
---@generic T
---@param name string Name of the property.
---@param changer fun(property: T): T
function M:change_property_by_using_curent(name, changer)
    local id = math.floor(math.random(1e10)) -- Get a unique id.
    self.socket:write(create_command("get_property", id, name))
    self.pair:read_start(function(data)
        for d in data:gmatch("[^\n]+") do
            d = vim.fn.json_decode(d)
            if d.error == "success" and d.request_id == id then
                self.socket:write(create_command("set_property", 0, name, changer(d.data)))
                self.pair:read_stop()
                return
            elseif d.request_id ~= id then
                error(("Failed to change property %s: %s"):format(name, d.error))
            end
        end
    end)
end

return M
