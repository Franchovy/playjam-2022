
function runTests()
    local tests <const> = {

    }

    for _, test in tests do
        if type(test) == "function" then
            test()
        end
    end
end