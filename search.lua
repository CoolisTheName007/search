---filesystem API by CoolisTheName007
--The hard work here was writing the iterators to be efficient; for instance they don't use coroutines or recursion.

---iterator over files/dirs in directory dir and with maximum depth of search depth, default is infinite
--following refer to the iterator returned, not the iterator created.
--@treturn string path
function iterTree(dir,depth)
	dir=dir or ''
	local index={0}
	local dir_index={0}
	local ts={{dir,fs.list(dir),{}}}
	local level=1
	local t_dir
	return function()
		repeat
			index[level]=index[level]+1
			name=ts[level][2][index[level]]
			if name==nil then
				if (not ts[level][4]) and ts[level][3][1] then
					ts[level][4]=true
					ts[level][2],ts[level][3]=ts[level][3],ts[level][2]
					index[level]=0
				else
					level=level-1
					if level==0 then return end
					dir=ts[level][1]
				end
			else
				t_dir=ts[level][1]..'/'..name
				if fs.isDir(t_dir) then
					if ts[level][4] then
						if depth~=level then
							level=level+1
							dir=t_dir
							ts[level]={dir,fs.list(dir),{}}
							index[level]=0
							dir_index[level]=0
						else
						end
					else
						dir_index[level]=dir_index[level]+1
						ts[level][3][dir_index[level]]=name
						break --send dir path
					end
				else
					break
				end
			end
		until false
		return dir..'/'..name
	end
end

---iterator over files in directory dir and with maximum depth of search depth, default is infinite
--following refer to the iterator returned, not the iterator created.
--@treturn string path
function iterFiles(dir,depth)
	--dir string = base directory; default ''
	--depth string = how many directories levels the iterator will open; default infinity
	--Example:
	-- for name,dir,index in iterFiles() do
	-- print('Returning:')
	-- print(name)
	-- print(dir)
	-- read()
	-- end
	--returns: iterator
	dir=dir or ''
	local index={0}
	local dir_index={0}
	local ts={{dir,fs.list(dir),{}}}
	local level=1
	local t_dir
	return function()
		repeat
			index[level]=index[level]+1
			name=ts[level][2][index[level]]
			if name==nil then
				if (not ts[level][4]) and ts[level][3][1] then
					ts[level][4]=true
					ts[level][2],ts[level][3]=ts[level][3],ts[level][2]
					index[level]=0
				else
					level=level-1
					if level==0 then return end
					dir=ts[level][1]
				end
			else
				t_dir=ts[level][1]..'/'..name
				if fs.isDir(t_dir) then
					if ts[level][4] then
						if depth~=level then
							level=level+1
							dir=t_dir
							ts[level]={dir,fs.list(dir),{}}
							index[level]=0
							dir_index[level]=0
						else
						end
					else
						dir_index[level]=dir_index[level]+1
						ts[level][3][dir_index[level]]=name
					end
				else
					break
				end
			end
		until false
		return dir..'/'..name
	end
end

---iterator over dirs in directory dir and with maximum depth of search depth, default is infinite
--following refer to the iterator returned, not the iterator created.
--@treturn string path
function iterDir(dir,depth)
	--dir string = base directory; default ''
	--depth integer = how many 'directory levels' the iterator will open; default infinity
	--Example:
	-- for dir,index in iterDir('',2) do
	-- print('Iter returned')
	-- print(dir)
	-- s=''
	-- for i,v in ipairs(index) do
		-- s=s..';'..v
	-- end
	-- print(s)
	-- read()
	-- end
	--returns: iterator
	dir=dir or ''
	local index={0}
	local dir_index={0}
	local ts={{dir,fs.list(dir),{},false}}
	local level=1
	local name, dir
	return function()
		dir=ts[level][1]
		repeat
			index[level]=index[level]+1
			name=ts[level][2][index[level]]
			if name==nil then
				index[level]=nil
				dir_index[level]=nil
				level=level-1
				if level==0 then
					return
				end
				dir=ts[level][1]
			elseif fs.isDir(dir..'/'..name) then break end
		until false
		dir_index[level]=dir_index[level]+1
		local t_index={}
		local t_dir=dir..'/'..name
		for i,v in ipairs(dir_index) do t_index[i]=dir_index[i] end
		if level~=depth then
			level=level+1
			index[level]=0
			dir_index[level]=0
			ts[level]={t_dir,fs.list(t_dir)}
		end
		return dir..'/'..name
	end
end

---returns name and expansion from a filepath.
--@param s filepath
--@return name
--@return expansion
function getNameExpansion(s)
	--s string = filename
	--returns: name, expansion
	--Example
	--print(getNameExpansion('filename.lua.kl'))
	--filename
	--lua.kl
	local _,_,name,expa=string.find(s, '([^%./\\]*)%.(.*)$')
	return name or s,expa
end


---WARNING: for compatibility with Lua ?, ? was replaced by # in globs; taken from https://github.com/davidm/lua-glob-pattern , by davidm
--only needed for filename conversion, slashes are dealt with directly for iteration purposes.
local function globtopattern(g)

  local p = "^"  -- pattern being built
  local i = 0    -- index in g
  local c        -- char at index i in g.

  
    -- unescape glob char
  local function unescape()
    if c == '\\' then
      i = i + 1; c = string.sub(g,i,i)
      if c == '' then
        p = '[^]'
        return false
      end
    end
    return true
  end

  -- escape pattern char
  local function escape(c)
    return c:match("^%w$") and c or '%' .. c
  end
  -- Convert tokens at end of charset.
  local function charset_end()
    while 1 do
      if c == '' then
        p = '[^]'
        return false
      elseif c == ']' then
        p = p .. ']'
        break
      else
        if not unescape() then break end
        local c1 = c
        i = i + 1; c = string.sub(g,i,i)
        if c == '' then
          p = '[^]'
          return false
        elseif c == '-' then
          i = i + 1; c = string.sub(g,i,i)
          if c == '' then
            p = '[^]'
            return false
          elseif c == ']' then
            p = p .. escape(c1) .. '%-]'
            break
          else
            if not unescape() then break end
            p = p .. escape(c1) .. '-' .. escape(c)
          end
        elseif c == ']' then
          p = p .. escape(c1) .. ']'
          break
        else
          p = p .. escape(c1)
          i = i - 1 -- put back
        end
      end
      i = i + 1; c = string.sub(g,i,i)
    end
    return true
  end

  -- Convert tokens in charset.
  local function charset()
    i = i + 1; c = string.sub(g,i,i)
    if c == '' or c == ']' then
      p = '[^]'
      return false
    elseif c == '^' or c == '!' then
      i = i + 1; c = string.sub(g,i,i)
      if c == ']' then
        -- ignored
      else
        p = p .. '[^'
        if not charset_end() then return false end
      end
    else
      p = p .. '['
      if not charset_end() then return false end
    end
    return true
  end
 --Convert tokens.
  while 1 do
	i = i + 1; c = string.sub(g,i,i)
    if c == '' then
      p = p .. '$'
      break
    elseif c == '#' then --?->#
      p = p .. '.'
    elseif c == '*' then
      p = p .. '.*'
    elseif c == '[' then
      if not charset() then break end
    elseif c == '\\' then
      i = i + 1; c = string.sub(g,i,i)
      if c == '' then
        p = p .. '\\$'
        break
      end
      p = p .. escape(c)
    else
      p = p .. escape(c)
    end
  end
  return p
end

---turns a glob into a table structure proper for iterPatterns.
local function compact(g)
	local nl={}
	local s1
	local n=0
	for c in string.gmatch(g,'[\\/]*([^/\\]*)[\\/]*') do
		--print(c)
		if c:match('^[%w%s]*$') then
			s1=s1 and s1..'/'..c or c
		else
			n=n+1
			nl[n]={s1,globtopattern(c)}
			s1=nil
		end
	end
	if s1 then
		if n==0 then
			n=n+1
			nl[n]={nil,s1}
		else
			nl[n][3]=s1
		end
	end
	return nl
end

---iterator creator over valid paths defined by a table with the structure: {t1,...,tn}, where ti is:
--Some special cases for small tables are handled diferently
--for i<n: {dir,pat} - dir is the directory where to look for names matching the pattern pat
--for i=n: {dir,pat,ending} -same but will combine the name (after successful match with pat) with the optional ending (can be nil) and check the resulting path
--e.g., g={{'APIS','*'},{nil,'A'},{'B/C','#','aq/qwerty'}} will search in all subfolders of APIS for subfolders named A, and in each of those for a folder B
--containing a folder C, and for all one-lettered folders in that folder for a folder aq containing a  folder/file named qwerty.
local function iterPatterns(l)
	local n=#l
	-- print('n',n)
	if n==0 then return function () return end end
	if n~=0 then l[1][1]=l[1][1] or '' end
	if n==1 and not l[1][3] then
		done=false
		return function ()
				if not done and fs_exists(l[1][2]) then
					done=true
					return l[1][2]
				end
			end
	end
	-- pprint(l)
	-- read()
	local dir=l[1][1]
	-- print('dir',dir)
	local index={0}
	local ts
	ts={{dir,fs_isDir(dir) and fs_list(dir) or {}}}
	-- read()
	-- pprint(ts)
	-- read()
	local level=1
	local t_dir
	local _
	return function()
		repeat
			index[level]=index[level]+1
			name=ts[level][2][index[level]]
			-- print('index:')
			-- pprint(index)
			-- print('level:',level)
			-- print('name:',name)
			-- print('dir:',dir)
			-- print('look:',l[level][2])
			-- print('match:',name and l[level] and l[level][2] and string.match(name,l[level][2]))
			-- read()
			if name==nil then
					-- print('name is nil')
					index[level]=nil
					level=level-1
					if level==0 then return end
					dir=ts[level][1]
			else
				if string.match(name,l[level][2]) then
					t_dir=dir..'/'..name
					-- print('t_dir:',t_dir)
					-- print('matches')
					-- print('level:',level)
					--pprint(l)
					-- read()
					if level==n then
						-- print('last level')
						_=l[level][3]
						if _ then
							t_dir=t_dir..'/'.._
							if fs_exists(t_dir) then
								path=t_dir
								break
							end
						else
							path=t_dir
							break
						end
					elseif fs_isDir(t_dir) then
						-- print('a dir!')
						level=level+1
						_=l[level][1]
						if _ then
							t_dir=t_dir..'/'.._
							if fs_exists(t_dir) then
								dir=t_dir
								ts[level]={dir,fs_list(dir)}
								index[level]=0
							else
								level=level-1
							end
						else
							dir=t_dir
							ts[level]={dir,fs_list(dir)}
							index[level]=0
						end
					end
				end
			end
		until false
		return path, index
	end
end

---iterator creator, over the valid paths defined by glob @g, e.g */filenumber?to
-- see the unix part of the table at http://en.wikipedia.org/wiki/Glob_(programming) .
--@treturn string path
--@usage
--for path in search.iterGlob('*/stuff?/a*') do
--	print(path)
--end
--APIS/stuff1/a.lua
--var/stuff2/a.var
function iterGlob(g)
	return iterPatterns(compact(g))
end


---returns the first path that matches the glob pattern g.
--@param g glob
function findfirst(g)
	for path in iterGlob(g) do
		return path
	end
end

---searches for the file fname (removing extensions)
--on the directory tree of _sPath (defaults to '')
--with maximum depth _nDepth (defaults to infinite).
--@treturn string path
function searchAll(fname,_sPath,_nDepth)
	assert(fname and (fname~=''),'search: invalid filename')
	_sPath=_sPath or ''
	for name,dir in iterFiles(_sPath,_nDepth) do
		if getNameExpansion(fname)==getNameExpansion(name) then
			return dir..'/'..name
		end
	end
end

---returns the first path that matches any of the glob patterns in string p (separated by ;) concatenated with glob pattern g.
--@usage search.searchGlob('*log*','APIS;packages/*;/')
--searches first in the directory 'APIS', then in the subdirectories of 'packages', then in the root directory '/' > packages/jumper/30log.lua  
--@treturn string path
function searchGlob(g,p)
	p=p or '/'
	local v
	for PATH in string.gmatch(p,'%;?([^%;]*)%;?') do
		v=findfirst(PATH..'/'..g)
		if v then return v end
	end
end

