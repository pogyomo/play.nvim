local job = require("play.job")
local cmd = require("play.player.mpv.command")
local socket_path = "/tmp/mpvsocket"

---A simple handler of mpv.
---@class MpvHandler
---@field mpv_job JobHandler JobHandler to handle mpv.
local M = {}

---Create a new MpvHandler instance.
---@return MpvHandler
function M:new()
    return setmetatable({
        mpv_job = job:new(),
    }, {
        __index = self
    })
end

---Whether mpv is running or not.
---@return boolean # True if mpv is running.
function M:is_running()
    return self.mpv_job:is_running()
end

---Execute command.
---@param name string Name of command.
---@param params any | any[] Parameters of this command.
---@param on_success? fun(data: table) Called when command is executed successfully.
function M:exec_command(name, params, on_success)
    if self:is_running() then
        cmd:new(socket_path):execute(name, params, on_success)
    end
end

---Change property by using given value
---@generic T
---@param name string Name of the property.
---@param value T Value to set.
---@param on_success? fun(data: table) Called when command is executed successfully.
function M:change_property(name, value, on_success)
    if self:is_running() then
        cmd:new(socket_path):change_property(name, value, on_success)
    end
end

---Change property changer.
---@generic T
---@param name string Name of the property.
---@param changer fun(property: T): T
---@param on_success? fun(data: table) Called when command is executed successfully.
function M:change_property_with(name, changer, on_success)
    if self:is_running() then
        cmd:new(socket_path):change_property_with(name, changer, on_success)
    end
end

---Play given file without video (only sound).
---@param path string
function M:start_file_without_video(path)
    self.mpv_job:start("mpv", {
        "--input-ipc-server=" .. socket_path,
        "--no-video",
        "--no-terminal",
        path,
    }, {
        on_exit = function()
            self:stop()
        end
    })
end

---Stop playback and exit from mpv.
function M:stop()
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
    self:change_property_with("pause", function(property)
        return not property
    end)
end

---Increase/Decrease the volume by given diff.
---@param diff integer How much to change volume.
function M:volume(diff)
    self:change_property_with("volume", function(property)
        return property + diff
    end)
end

return M
