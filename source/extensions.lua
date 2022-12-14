
-- Extensions on "table"

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

function table.removekey(table, key)
   local element = table[key]
   table[key] = nil
   return element
end

function table.removevalue(table, value)
   for k, v in pairs(t) do
	   if v == value then
		   table[k] = nil
	   end
   end
end

function table.find(table, value)
	for _,v in pairs(items) do
	  	if v == value then
			return v
	  	end
	end	
end

-- Extensions on "math"

function math.approach( value, target, step)
	if value==target then
		return value, true
	end

	local d = target-value
	if d>0 then
		value = value + step
		if value >= target then
			return target, true
		else
			return value, false
		end
	elseif d<0 then
		value = value - step
		if value <= target then
			return target, true
		else
			return value, false
		end
	else
		return value, true
	end
end