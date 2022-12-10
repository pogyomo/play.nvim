# Core module

## Introduction

This module provide primitive interface to play music/video.

## Methods

```lua
core:new(backend)
```

**Description**

Create a new core instance.

**Parameters**

- `backend: string` Name of player to use as backend. Below player is available.
    - `"mpv"` mpv media player.

**Returns**

- core instance.

```lua
core:loadfile(path)
```

**Description**

Open music/video from given path/url.

**Parameters**

- `path: string` Path or url to play.

**Returns**

- Nothing

```lua
core:loadlist(list)
```

**Description**

Open list of path/url as playlist.

**Parameters**

- `list: string[]` List of path/url.

**Returns**

- Nothing

```lua
core:stop()
```

**Description**

Stop playback and delete loaded playlist or music/video.
Music/Video won't be played any more without calling loadfile/loadlist.

**Parameters**

- Nothing

**Returns**

- Nothing

```lua
core:play_next()
```

**Description**

Play next music/video.

**Parameters**

- Nothing

**Returns**

- Nothing

```lua
core:play_prev()
```

**Description**

Play previous music/video.

**Parameters**

- Nothing

**Returns**

- Nothing

```lua
core:pause()
```

**Description**

Pause current playback.

**Parameters**

- Nothing

**Returns**

- Nothing

```lua
core:resume()
```

**Description**

Resume current playback.

**Parameters**

- Nothing

**Returns**

- Nothing

```lua
core:toggle()
```

**Description**

Toggle pause and resume.

**Parameters**

- Nothing

**Returns**

- Nothing

```lua
core:seek(value, behavior, exceed)
```

**Description**

Change current playback position by using given value. Changed position must be between 0 and duration.

**Parameters**

- `value: integer` Value to be used to change volume.
- `behavior: string?` How to use `value`. Below is available.
    - `"relative": default` Change position by adding value to current position.
    - `"absolute"`          Use value as current position.
- `exceed: string?` What happen when changed position become position < 0 or position > duration
    - `"error: default"` Cause error. Nothing change.
    - `"round"`          Change to 0 or 100 if position < 0 or position > duration

**Returns**

- Nothing

```lua
core:volume(value, behavior, exceed)
```

**Description**

Change current volume by using given value. Changed volume must be between 0 and 100.

**Parameters**

- `value: integer` Value to be used to change volume.
- `behavior: string?` How to use `value`. Below is available.
    - `"relative": default` Change volume by adding value to current volume.
    - `"absolute"`          Use value as current volume.
- `exceed: string?` What happen when changed volume become volume < 0 or volume > 100
    - `"error: default"` Cause error. Nothing change.
    - `"round"`          Change to 0 or 100 if volume < 0 or volume > 100

**Returns**

- Nothing

