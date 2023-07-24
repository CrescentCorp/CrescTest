export type skip = () -> ()
export type lifecycleFunctions = "afterAll" | "afterEach" | "beforeAll" | "beforeEach"

export type TestCaseResult = { ok: boolean, err: string? }
export type TestSuiteResult = { [string]: TestCaseResult }
export type TestSuite = {
	[string]: (skip: skip, ...any) -> (),
}

local task = task or require("@lune/task")
local CrescTest = {}

local lifecycleFunctions = {
	afterAll = true,
	afterEach = true,
	beforeAll = true,
	beforeEach = true,
}

local function empty() end

local function getDictonaryCount(dictonary, predicate)
	local count = 0

	for name, value in dictonary do
		if predicate(name, value) then
			count += 1
		end
	end

	return count
end

local function testPredicate(name, ...)
	if not lifecycleFunctions[name] then
		return true
	end

	return false
end

function CrescTest.runSuite(TestSuite: TestSuite, context: any): TestSuiteResult
	local result: TestSuiteResult = {}
	local afterAll = TestSuite.afterAll or empty
	local afterEach = TestSuite.afterEach or empty
	local beforeAll = TestSuite.beforeAll or empty
	local beforeEach = TestSuite.beforeEach or empty

	beforeAll(empty, context)
	for testCaseName, testCase in TestSuite do
		if not lifecycleFunctions[testCaseName] then
			beforeEach(empty, context)

			local isSkipped
			local isOk, response = pcall(testCase, function()
				isSkipped = true
				error("")
			end, context)

			if isSkipped then
				afterEach(empty, context, true)
				continue
			end
			
			result[testCaseName] = { ok = isOk, err = response }
			afterEach(empty, context, false)
		end
	end
	afterAll(empty, context)
	return result
end

if script then -- this is roblox, lets setup a bootstrapper for it
-- TODO: work on it
else -- this is in a lune env, lets setup a bootstrapper that depends on fs
	local fs = require("@lune/fs")
	local stdio = require("@lune/stdio")

	local function getDescendents(dir, result)
		local contents = fs.readDir(dir)

		for _, name in contents do
			local path = `{dir}/{name}`

			if fs.isDir(path) then
				getDescendents(path, result)
			else
				result[path] = true
			end
		end

		return result
	end

	function CrescTest.run(dir: string, context: any)
		local result = {}

		for path in getDescendents(dir, {}) do
			if not string.find(path, "spec") then
				continue
			end
			result[path] = CrescTest.runSuite(require(`../{path}`), context)
		end

		local resultString = ""

		for file, testSuiteResult in result do
			local scopedResult = {}
			for testCase, testResult in testSuiteResult do
				table.insert(
					scopedResult,
					`   {testCase} .. {if testResult.ok
						then stdio.color("green") .. "Passed" .. stdio.color("reset")
						else stdio.color("red") .. "Failed" .. stdio.color("reset")}`
				)
			end

			resultString ..= `\n{file}: \n {table.concat(scopedResult, "\n ")}`
		end

		print(resultString)
	end
end

function CrescTest.expect(input): any
	return setmetatable({
		_never = false,
	}, {
		__index = function(self, queryName)
			if queryName == "never" then
				self._never = not self._never
			end

			if queryName == "ok" then
				return function()
					local never = self._never
					local result = input ~= nil

					if never then
						result = not result
					end

					assert(result, `Expected value to{if never then " never" else ""} exist`)
				end
			end

			if queryName == "equal" or queryName == "equals" then
				return function(expectedValue)
					local never = self._never
					local result = input == expectedValue

					if never then
						result = not result
					end

					assert(
						result,
						string.format(
							`Expected value to{if never then " never" else ""} be equal to {expectedValue}, got {input}`
						)
					)
				end
			end

			if queryName == "near" then
				return function(expectedValue)
					local never = self._never
					local result = math.round(input) == math.round(expectedValue)

					if never then
						result = not result
					end

					assert(
						result,
						string.format(
							`Expected value to{if never then " never" else ""} be near to {expectedValue}, got {input}`
						)
					)
				end
			end

			if queryName == "a" then
				return function(expectedType)
					local never = self._never
					local result = typeof(input) == expectedType

					if never then
						result = not result
					end

					assert(
						result,
						string.format(
							`Expected value to{if never then " never" else ""} have type of {expectedType}, got {typeof(input)}`
						)
					)
				end
			end
			return self
		end,
	}) :: any
end

return CrescTest
