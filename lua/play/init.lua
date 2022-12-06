local mpv = require("play.player.mpv")

local M = {
    mpv = mpv:new()
}

function M:start()
    self.mpv:start_file_without_video("~/number.mkv")
end

function M:stop()
    self.mpv:stop()
end

function M:change()
    self.mpv:loadfile("~/number_sappukei.mp4")
end

function M:seek()
    self.mpv:seek(-10)
end

function M:pause()
    self.mpv:pause()
end

function M:resume()
    self.mpv:resume()
end

function M:toggle()
    self.mpv:toggle()
end

function M:dec()
    self.mpv:volume(-10)
end

function M:inc()
    self.mpv:volume(10)
end

return M
