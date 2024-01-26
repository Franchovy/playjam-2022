import "tests/collisionTests"

function runTests()
    local tests <const> = {
        collisionTests
    }

    for _, test in pairs(tests) do
        if type(test) == "function" then
            test()
        end
    end
end