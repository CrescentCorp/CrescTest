local lib = require(game:GetService("ServerScriptService").CrescTest)

return {
    should_add_well = function()
        lib.expect(1 + 1).to.equal(2)
    end,
    should_subtract_well = function()
        lib.expect(1 - 1).to.equal(0)
    end,
    should_do_something_complex = function(skip)
        --skip()
        task.wait(2)
        lib.expect(1 - 1).to.equal(1)
    end
}