<h1 align="center">
	CrescTest
</h1>
<h3 align="center">
	Unit Testing in Luau SuperCharged
</h3>

____

CrescTest is a runtime-agnostic Luau unit testing framework, with a focus on simplicity, and cross-runtime testing. 

### Origin
CrescTest isn't the first unit testing framework I wrote. In fact, its a successor to the Unit testing framework that libraries like Vinum and BridgeNet2 use.

CrescTest has been made to improve what the Orginial framework didn't do well,  and to provide what it lacked.
For example:
1. Improved error reporting
2. Cross-runtime testing
3. Extremely lightweight.
4. Ability to skip test cases.
5. lifecycle functions.

### API

```lua
export type skip = () -> ()
export type lifecycleFunctions = "afterAll" | "afterEach" | "beforeAll" | "beforeEach"

export type TestCaseResult = { ok: boolean, err: string? }
export type TestSuiteResult = { [string]: TestCaseResult }
export type TestSuite = {
	[string]: (skip: skip, ...any) -> (),
}
```
All custom types used within CrescTest.

```lua
function CrescTest.run(dir: string, context: any)
```

A bootstrapper intended for usage using lune.

* dir: A path to the folder you want to run all .spec files that are present
* context: any value that you would want all tests to access it

```lua
function CrescTest.runSuite(TestSuite: TestSuite, context: any): TestSuiteResult
```

A runtime-agnostic method for running test suites.

* TestSuite: a table of test cases.
* context: any value that you would want all tests to access it.

```lua
function CrescTest.expect(input: any)
```
Takes in an input, that then gets used in assertions

* `.never` - Reverses the result of the assertion.
* `.ok()` - Asserts that value is non-nil
* `.equal/equals(expectedValue)`-  - Asserts that value is equal to expectedValue.
* `.near(value)` - Asserts that the rounded version of input equals the rounded version of value
* `.a(expectedType)` - Asserts that the `typeof(input)` equals to expectedType.
* `.any.thing.that.is.not.part.of.the.api` - Does nothing, so you are able to write scentences.

```
x.spec.luau
```

A file that has a bunch of TestCases. 
```lua
return {
    should_add_well = function()
        CrescTest.expect(1 + 1).to.equal(2)
    end,
    should_subtract_well = function()
        CrescTest.expect(1 - 1).to.equal(0)
    end,
    should_do_something_complex = function(skip)
        --skip()
        task.wait(2)
        CrescTest.expect(1 - 1).to.equal(1)
    end
}
```