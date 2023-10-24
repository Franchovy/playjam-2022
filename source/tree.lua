
class("Tree").extends()

function Tree:init(object)
	-- Node contains object and children
	
	local initialNode = { 
		object = object,
		children = {}
	}
	
	self._node = initialNode
end

-- Parent is the key to a node on the tree
function Tree:addChild(parentNode, childObject)
	local childNode = {
		object = childObject,
		children = {}
	}
	
	table.insert(parentNode.children, childNode)
end

-- Iterate over tree until a match is found (Breadth-first search)
function Tree:find(targetObject)
	-- Search is performed by appending children to a buffer of search elements
	local buffer = {
		self._node
	}
	
	while #buffer > 0 do
		local node = table.remove(buffer, 1)
		if node.object == targetObject then
			return node
		end
		
		local children = node.children
		
		for _, c in pairs(children) do
			table.insert(buffer, c)
		end
	end
end
