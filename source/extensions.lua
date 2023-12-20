
-- Extensions on "table"

function table.last(t)
	return t[#t]
end

function table.values(inputTable)
	local values = {}
	
	for _, value in pairs(inputTable) do
		table.insert(values, value)
	end
	
	return values
end

function table.keys(inputTable)
	local keys = {}
	
	for key, _ in pairs(inputTable) do
		table.insert(keys, key)
	end
	
	return keys
end

function table.firstIndex(t, fn)
	for i, e in ipairs(t) do
		if fn(e) then
			return i
		end
	end
end

function table.each( t, fn )
	if type(fn)~="function" then return end
	for _, e in pairs(t) do
		fn(e)
	end
end

function table.imap( t, fn)
		local results = {}
		for i, e in ipairs(t) do
			results[i] = fn(i)
		end
		return results
	end

function table.map( t, fn)
	local results = {}
	for i, e in ipairs(t) do
		results[i] = fn(e)
	end
	return results
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

function table.contains(t, value)
	for _, v in pairs(t) do
		if v == value then 
			return true
		end
	end
	return false
end

function table.removekey(t, key)
   local element = t[key]
   t[key] = nil
   return element
end

function table.removevalue(t, value)
   for k, v in pairs(t) do
	   if v == value then
		   t[k] = nil
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

function table.setIfNil(table, key)
	if table[key] == nil then
		table[key] = {}
	end
end

function table.deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[table.deepcopy(orig_key)] = table.deepcopy(orig_value)
		end
		setmetatable(copy, table.deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

function table.shallowEqual(table1, table2)
	for k, v in pairs(table1) do
		if table2[k] == nil or table1[k] ~= table2[k] then
			return false
		end
	end
	
	return true
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

function math.clamp(value, min, max)
	return math.max(math.min(value, max), min)
end

function math.sign(value)
	if value < 0 then
		return -1
	elseif value > 0 then
		return 1
	elseif value == 0 then
		return 0
	end
end

-- Useful methods

function setIfNil(value, valueIfNil)
	if value == nil then
		value = valueIfNil
	end
end