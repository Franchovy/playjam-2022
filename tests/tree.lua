
-- Tests

import "tree"

function test()
	print("Running tests...")
	
	local myobject = { name = "root" }
	local myobject2 = { name = "child1" }
	local myobject3 = { name = "child2" }
	local myobject4 = { name = "grandchild1" }
	local tree = Tree(myobject)
	
	local node = tree:find(myobject)
	assert(node.object == myobject)
	assert(node.children ~= nil)
	assert(#node.children == 0)
	
	tree:addChild(node, myobject2)
	tree:addChild(node, myobject3)
	
	assert(#node.children == 2)
	
	local nodeObject2 = tree:find(myobject2)
	assert(nodeObject2 ~= nil)
	assert(nodeObject2.object == myobject2)
	assert(nodeObject2.children ~= nil)
	assert(#nodeObject2.children == 0)
	
	tree:addChild(nodeObject2, myobject4)
	
	assert(#nodeObject2.children == 1)
	
	local nodeObject4 = tree:find(myobject4)
	assert(nodeObject4 ~= nil)
	
	print("Finished tests.")
end
