local lib = require("../../lib")

local you = "idiot"

return {
    testCase1 = function()
        lib.expect(you).to.equal("special man")
    end
}