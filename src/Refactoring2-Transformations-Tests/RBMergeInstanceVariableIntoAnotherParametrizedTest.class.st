Class {
	#name : #RBMergeInstanceVariableIntoAnotherParametrizedTest,
	#superclass : #RBWithDifferentConstructorsParametrizedTest,
	#category : #'Refactoring2-Transformations-Tests-Parametrized'
}

{ #category : #tests }
RBMergeInstanceVariableIntoAnotherParametrizedTest class >> testParameters [
	^ ParametrizedTestMatrix new
		addCase: { #rbClass -> RBMergeInstanceVariableIntoAnother .
					  #constructor -> #rename:to:in: };
		addCase: { #rbClass -> RBMergeInstanceVariableIntoAnotherTransformation .
					  #constructor -> #renameInstanceVarible:to:in: };
		yourself
]

{ #category : #'failure tests' }
RBMergeInstanceVariableIntoAnotherParametrizedTest >> testEqualsVariables [
	self shouldFail: (self createRefactoringWithArguments: 
		{ 'classBlock' . 'classBlock' . RBBasicLintRuleTestData })
]

{ #category : #'failure tests' }
RBMergeInstanceVariableIntoAnotherParametrizedTest >> testNonExistingVariable [
	self shouldFail: (self createRefactoringWithArguments: 
		{ 'classBlock' . 'anInstVar1' . RBBasicLintRuleTestData })
]

{ #category : #tests }
RBMergeInstanceVariableIntoAnotherParametrizedTest >> testReplaceVariableIntoAnother [
	| refactoring class |
	refactoring := self createRefactoringWithArguments: 
		{ 'classBlock' . 'anInstVar' . RBBasicLintRuleTestData }.
	class := refactoring model classNamed: #RBBasicLintRuleTestData.
	self assert: (class whichSelectorsReferToInstanceVariable: 'classBlock') isNotEmpty.
	self executeRefactoring: refactoring.
	
	self assert: (class whichSelectorsReferToInstanceVariable: 'classBlock') isEmpty.
]

{ #category : #tests }
RBMergeInstanceVariableIntoAnotherParametrizedTest >> testReplaceVariableIntoSupeclassVariable [
	| refactoring class |
	refactoring := self createRefactoringWithArguments: 
		{ 'name' . 'classBlock' . RBBasicLintRuleTestData }.
	class := refactoring model classNamed: #RBBasicLintRuleTestData.
	self assert: (class whichSelectorsReferToInstanceVariable: 'name') isNotEmpty.
	self executeRefactoring: refactoring.
	self assert: (class definesInstanceVariable: 'name').
	self assert: (class directlyDefinesInstanceVariable: 'classBlock').
	
	self assert: (class whichSelectorsReferToInstanceVariable: 'name') isEmpty.
]
