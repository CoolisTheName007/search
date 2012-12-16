search=require'packages.search'
setmetatable(getfenv(),{__index=setmetatable(search,{__index=_G})})--the equivalent of from search import *
test=function(spath,depth)
	print('test')
	print(spath)
	print(depth)
	print('iterTree')
	read()
	for path in iterTree(spath,depth) do
		print(path)
	end
	print('iterFiles')
	read()
	for path in iterFiles(spath,depth) do
		print(path)
	end
	print('iterDir')
	read()
	for path in iterDir(spath,depth) do
		print(path)
	end
end

-- test()
-- test('/')
-- test(nil,2)
-- test('packages',1)

for path in iterGlob('packages/*/init.lua') do
	print(path)
end