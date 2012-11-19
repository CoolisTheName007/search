# File Search API #


This API implements non-recursive coroutine-free directory full tree iterators,one of which can take a [glob](http://en.wikipedia.org/wiki/Glob_(programming\)) expression as input.

Full documentation is in comments inside search.lua, until I get automatic html documentation working.

This was motivated by the lack of require in ComputerCraft, and I guess the same happens in most Lua sandboxes for security reasons.

