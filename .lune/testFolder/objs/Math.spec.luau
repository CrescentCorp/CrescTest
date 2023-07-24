local lib = require("../../../lib")
local task = task or require("@lune/task")
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
        lib.expect(1 - 1).to.never.equal(1)
    end
}