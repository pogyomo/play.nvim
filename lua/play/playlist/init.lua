---A class to manage playlists.
---@class PlaylistManager
---@field name_to_playlist table<string, PlaylistData>

---A class to represent a playlist.
---@class PlaylistData
---@field path_list string[]

---@class PlaylistManagerAddOption
---@field force boolean When true, overwrite exist playlist.

---@class PlaylistManager
local M = {}

---Create a new PlaylistManager instance.
---@return PlaylistManager
function M:new()
    return setmetatable({
        name_to_playlist = {}
    }, {
        __index = self
    })
end

---Add a playlist with name.
---@param name string Name of the playlist.
---@param playlist PlaylistData The playlist to add.
---@param opts PlaylistManagerAddOption Options. 
function M:add(name, playlist, opts)
    if self.name_to_playlist[name] and opts.force then
        self.name_to_playlist[name] = playlist
    else
        self.name_to_playlist[name] = self.name_to_playlist[name] or playlist
    end
end

---Take a playlist which associated with the name.
---@param name string Name of target playlist.
---@return PlaylistData | nil # Nil if there is no such playlist.
function M:take(name)
    return self.name_to_playlist[name]
end

return M
