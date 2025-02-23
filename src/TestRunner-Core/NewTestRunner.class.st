"
I am a TestRunner. I run tests and export the result from:
	- TestClass (TestRunner)
	- TestCase
	- TestSuite
	- aRPackage.

You can simply use my method (NewTestRunner class run: aRunnable) to run all the previous elements.

# Public API
- suitePreparator:
- runClass:
- runCase:
- runSuite:
- runPackage:
- runFailures
- runErrors
- result

- switchToDebugMode
- switchToRunMode
- accumulateResult
- doNotAccumulateResult

- ...

"
Class {
	#name : #NewTestRunner,
	#superclass : #Object,
	#instVars : [
		'suite',
		'result',
		'suitePreparator',
		'shouldAccumulate',
		'executionMode'
	],
	#category : #'TestRunner-Core-Core'
}

{ #category : #running }
NewTestRunner class >> example [
	<script>
	self new 
	suitePreparator: ShuffleSuitePreparator;
	run: DependencyTest;
	inspect
]

{ #category : #tests }
NewTestRunner class >> isValidClass: aClass [

	| criterias |
	criterias := { 
		             [ :class | class isTestCase ].
		             [ :class | class isAbstract not ] }.

	^ criterias allSatisfy: [ :criteria | criteria value: aClass ]
]

{ #category : #running }
NewTestRunner class >> run: aRunnable [

	^ self new
		  run: aRunnable;
		  result
]

{ #category : #running }
NewTestRunner class >> runCase: aTestCase [

	"return the result of the execution of the giving testCase"

	^ self new
		  runCase: aTestCase;
		  result
]

{ #category : #running }
NewTestRunner class >> runClass: aTestClass [

	^ self new runClass: aTestClass
]

{ #category : #running }
NewTestRunner class >> runPackage: aRPackage [

	"return the result of the execution of the giving package"

	^ self new
		  runPackage: aRPackage;
		  result
]

{ #category : #running }
NewTestRunner class >> runSuite: aTestSuite [

	"return the result of the execution of the giving testSuite"

	^ self new
		  runSuite: aTestSuite;
		  result
]

{ #category : #processing }
NewTestRunner >> accumulateResult [

	"activate the results accumulation behavior"

	self shouldAccumulate: true
]

{ #category : #internal }
NewTestRunner >> addError: aTestError [

	"store the giving testCase as Error in result"

	self result addError: aTestError
]

{ #category : #internal }
NewTestRunner >> addFailure: aTestFailure [

	"store the giving testCase as Failure in result"

	self result addFailure: aTestFailure
]

{ #category : #internal }
NewTestRunner >> addPass: aPassedTest [

	"store the giving testCase as passed test in result"

	self result addPass: aPassedTest
]

{ #category : #internal }
NewTestRunner >> addToSuite: aTestSuite [

	"add the giving testsuite to the current suite. Notice that only the tests are added"

	suite := self suite , aTestSuite
]

{ #category : #running }
NewTestRunner >> debugFailure: failure [

	"debug the giving failure"


	self executionMode debugFailure: failure
]

{ #category : #accessing }
NewTestRunner >> defaultExecutionEnvironmentClass [

		
	^ self defaultExecutionEnvironmentClass
]

{ #category : #accessing }
NewTestRunner >> defaultExecutionModeClass [

	^ RunExecutionMode
]

{ #category : #accessing }
NewTestRunner >> defaultSuitePreparator [

	^ AnyEffectSuitePreparator
]

{ #category : #accessing }
NewTestRunner >> defaultTestResultClass [

	^ TestResult
]

{ #category : #processing }
NewTestRunner >> doNotAccumulateResult [


	"disable the results accumulation behavior"


	self shouldAccumulate: false
]

{ #category : #accessing }
NewTestRunner >> errorCount [


	"returns the number of testcase which failed du to error during the execution"

	^ result errorCount
]

{ #category : #accessing }
NewTestRunner >> executionMode [

	^ executionMode ifNil: [ self defaultExecutionModeClass ]
]

{ #category : #setter }
NewTestRunner >> executionMode: anExecutionMode [

	executionMode := anExecutionMode
]

{ #category : #accessing }
NewTestRunner >> failureCount [

	"returns the number of testcase which failed du to assertion error during the execution"


	^ self result failureCount
]

{ #category : #testing }
NewTestRunner >> hasTestsToRun [

	"check either the runner has test to run or not.

	If any test has not been collected, there nothing to run"


	^ self suite tests isNotEmpty
]

{ #category : #initialization }
NewTestRunner >> initialize [

	super initialize.
	self doNotAccumulateResult
]

{ #category : #accessing }
NewTestRunner >> passedCount [


	"return the number of passed testcase"

	^ self result passedCount
]

{ #category : #internal }
NewTestRunner >> resetResult [

	"reset the runner result"

	result := self defaultTestResultClass new
]

{ #category : #internal }
NewTestRunner >> resetSuite [

	suite := nil
]

{ #category : #accessing }
NewTestRunner >> result [

	^ result ifNil: [ result := self defaultTestResultClass new]
]

{ #category : #accessing }
NewTestRunner >> resultDescription [

	"return the description of test case"

	^ result asString
]

{ #category : #accessing }
NewTestRunner >> run: aRunnable [

	aRunnable runBy: self.
	^ self result
]

{ #category : #running }
NewTestRunner >> runAll [


	"run the current collected suite"


	[ 
	self setUp.
	self runSuite ] ensure: [ self tearDown ]
]

{ #category : #running }
NewTestRunner >> runCase: aTestCase [

	"run and return the result of the fiving testCase"


	| executionResult |
	executionResult := self executionMode executeCase: aTestCase.
	self result + executionResult.
	^ executionResult
]

{ #category : #running }
NewTestRunner >> runClass: aClass [


	"run and return the result of the giving class"

	self shouldAccumulate ifFalse: [ self resetResult ].
	self testSuiteFromClass: aClass.
	self suite name: aClass name.

	self runAll.

	^ result
]

{ #category : #running }
NewTestRunner >> runClasses: aCollectionOfTestCases [

	"run and return the result of the giving collection of classes"

	self accumulateResult.
	aCollectionOfTestCases do: [ :class | 
		class isAbstract ifFalse: [ self runClass: class ] ].
	^ result
]

{ #category : #accessing }
NewTestRunner >> runCount [

	"returns the number of executed testcase"


	^ self result runCount
]

{ #category : #running }
NewTestRunner >> runError: aTestCase [

	"run the giving testCase and update the result. 
	Usefull if we want only to rerun the failure after some execution. See self >> runErrors"

	| rerunningResult |
	rerunningResult := aTestCase run.
	rerunningResult hasPassed ifTrue: [ result removeError: aTestCase ].
	self updateResultWith: rerunningResult

]

{ #category : #running }
NewTestRunner >> runErrors [


	"rerun the failed testcases du to error"


	self result errors do: [ :testCase | self runError: testCase ]
]

{ #category : #running }
NewTestRunner >> runFailure: aTestCase [

	"rerun the giving failure then update the result"

	| rerunningResult |
	rerunningResult := aTestCase run.

	rerunningResult hasPassed ifTrue: [ result removeFailure: aTestCase ].
	self updateResultWith: rerunningResult
]

{ #category : #running }
NewTestRunner >> runFailures [


	"rerun the failed testcases du to assertion failure"

	self result failures do: [ :testCase | self runFailure: testCase ]
]

{ #category : #running }
NewTestRunner >> runPackage: aRPackage [

	"run the tests from the giving package"


	self shouldAccumulate ifFalse: [ self resetResult ].
	self testSuiteFromPackage: aRPackage.
	self runAll
]

{ #category : #running }
NewTestRunner >> runPackages: aCollection [

	"run tests from the giving collections of package"

	self accumulateResult.
	aCollection do: [ :package | self runPackage: package ]
]

{ #category : #running }
NewTestRunner >> runSuite [

	"run the tests from the current collected suite"

	self suite tests do: [ :aTestCase | self runCase: aTestCase ]
]

{ #category : #running }
NewTestRunner >> runSuite: aTestSuite [

	"run tests from the giving testsuite"

	self suite: aTestSuite.
	self runAll
]

{ #category : #processing }
NewTestRunner >> setUp [

	"we would like to process suites before execution (e.g shufling the tests for exemple).
	see AbstractSuitePreparator"


	self suitePreparator applyOn: self suite
]

{ #category : #tests }
NewTestRunner >> shouldAccumulate [

	^ shouldAccumulate
]

{ #category : #setter }
NewTestRunner >> shouldAccumulate: aBoolean [

	shouldAccumulate := aBoolean
]

{ #category : #testing }
NewTestRunner >> someTestCausesError [

	^ result hasErrors
]

{ #category : #testing }
NewTestRunner >> someTestFailed [

	"Tell if some test failed during execution"

	^ self result hasFailures
]

{ #category : #accessing }
NewTestRunner >> suite [

	^ suite ifNil: [ suite := TestSuite new ]
]

{ #category : #setter }
NewTestRunner >> suite: aTestSuite [

	suite := aTestSuite
]

{ #category : #accessing }
NewTestRunner >> suitePreparator [

	^ suitePreparator ifNil: [ 
		  suitePreparator := self defaultSuitePreparator ]
]

{ #category : #setter }
NewTestRunner >> suitePreparator: aSuitePreparator [

	suitePreparator := aSuitePreparator
]

{ #category : #processing }
NewTestRunner >> switchToDebugMode [

	self executionMode: DebugExecutionMode
]

{ #category : #processing }
NewTestRunner >> switchToRunMode [

	self executionMode: RunExecutionMode
]

{ #category : #processing }
NewTestRunner >> tearDown [

	"after the execution of the collected suite. We put here the instruction to execute"

	self resetSuite
]

{ #category : #internal }
NewTestRunner >> testSuiteFromClass: aClass [

	"build a suite from the giving class then add it to the internal collections of suites. 
	If it doesn't respect some criteria, nothing won't be collected. (See self class >> isValidClass)"


	(self class isValidClass: aClass) ifTrue: [ 
		self addToSuite: aClass suite ]
]

{ #category : #internal }
NewTestRunner >> testSuiteFromPackage: aRPackage [

	"Build testsuite from the giving Package"


	aRPackage definedClasses do: [ :c | self testSuiteFromClass: c ].
	self suite name: aRPackage name
]

{ #category : #internal }
NewTestRunner >> testSuitesFromClasses: aCollectionOfClass [

	"Build testsuite from the giving collection of class"


	aCollectionOfClass do: [ :class | 
		self suite addTests: class suite tests ]
]

{ #category : #accessing }
NewTestRunner >> testsCount [

	"return the number of collected testCase"


	^ self result tests size
]

{ #category : #internal }
NewTestRunner >> updateResultWith: testResult [

	"Merge the current result with the giving one then return it"


	self result + testResult.
	^ result
]
