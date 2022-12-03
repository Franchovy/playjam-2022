
-- "For Each" equivalent

function table.each( t, fn )
	if type(fn)~="function" then return end
	for _, e in pairs(t) do
		fn(e)
	end
end

function table.filter(t)
if t == nil then return {} end
	local array = {}
	for _, e in pairs(t) do
		if e ~= nil and e ~= false then
			table.insert(array, e)
		end
	end
	return array
end