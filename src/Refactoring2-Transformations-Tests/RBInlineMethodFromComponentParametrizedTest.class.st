Class {
	#name : #RBInlineMethodFromComponentParametrizedTest,
	#superclass : #RBAbstractRefactoringTest,
	#category : #'Refactoring2-Transformations-Tests-SingleParametrized'
}

{ #category : #tests }
RBInlineMethodFromComponentParametrizedTest class >> testParameters [
	^ ParametrizedTestMatrix new
		addCase: { #rbClass -> RBInlineMethodFromComponentRefactoring };
		yourself
]

{ #category : #accessing }
RBInlineMethodFromComponentParametrizedTest >> constructor [ 
	^ #inline:inMethod:forClass:
]

{ #category : #tests }
RBInlineMethodFromComponentParametrizedTest >> testInlineComponentIntoCascadedMessage [
	| refactoring |
	self proceedThroughWarning: 
		[ refactoring := self createRefactoringWithArguments:  
				{(35 to: 79) . #inlineComponent . RBRefactoryTestDataApp}.
		(refactoring model classNamed: #Behavior) 
			compile: 'hasImmediateInstances ^self format = 0'
			classified: #(#accessing ).
		self 
			setupInlineExpressionFor: refactoring
			toReturn: false.
		self executeRefactoring: refactoring ].
	self assert: ((refactoring model classNamed: #RBRefactoryTestDataApp) 
		parseTreeFor: #inlineComponent) 
		equals: (self parseMethod: 'inlineComponent
	| a aBehavior |
	a := 5.
	aBehavior := a class.
	aBehavior superclass.
	aBehavior format = 0.
	^aBehavior yourself')
]

{ #category : #tests }
RBInlineMethodFromComponentParametrizedTest >> testInlineComponentMethodMax [
	| refactoring |
	self proceedThroughWarning: [ | class |
			refactoring := self createRefactoringWithArguments:
				{ (47 to: 58) . #inlineMax . RBRefactoryTestDataApp }.
			self setupInlineExpressionFor: refactoring toReturn: true.
			class := refactoring model classNamed: #Magnitude.
			class
				compile:
					'max: aMagnitude 
					"Answer the receiver or the argument, whichever has the greater magnitude."

					self > aMagnitude
						ifTrue: [^self]
						ifFalse: [^aMagnitude]'

			classified: #(#accessing ).
		self 
			setupImplementorToInlineFor: refactoring
			toReturn: class.
		self executeRefactoring: refactoring ].
	self assert: ((refactoring model classNamed: #RBRefactoryTestDataApp) parseTreeFor: #inlineMax) equals: (self parseMethod: 'inlineMax
								| x y q |
								x := 5.
								y := 10.
								q := x + 1 > y
									ifTrue: [x + 1]
									ifFalse: [y].
								^q')
]

{ #category : #tests }
RBInlineMethodFromComponentParametrizedTest >> testInlineEmptyComponentMethod [
	| refactoring |

	self proceedThroughWarning: 
		[ refactoring := self createRefactoringWithArguments: 
			 { (35 to: 91) . #inlineComponent . RBRefactoryTestDataApp }.
		self 
			setupInlineExpressionFor: refactoring
			toReturn: false.
		"The following line is needed because some people implement #yourself themselves."
		self 
			setupImplementorToInlineFor: refactoring
			toReturn: (refactoring model classNamed: #Object).
		self executeRefactoring: refactoring ].
	self assert: ((refactoring model classNamed: #RBRefactoryTestDataApp) 
		parseTreeFor: #inlineComponent) 
		equals: (self parseMethod: 'inlineComponent
	| a anObject |
	a := 5.
	anObject := a class.
	anObject superclass.
	anObject hasImmediateInstances.
	^anObject')
]

{ #category : #'failure tests' }
RBInlineMethodFromComponentParametrizedTest >> testInlineMethodFromComponentFailure [
	self shouldFail: (self createRefactoringWithArguments:
		{ (50 to: 64) . #inlineFailed . RBRefactoryTestDataApp })
]

{ #category : #tests }
RBInlineMethodFromComponentParametrizedTest >> testModelInlineMethodWithSameVariableNames [
	| class refactoring |
	model := RBClassModelFactory rbNamespace new.
	class := model classNamed: self class name.
	class compile: 'a9: a b9: b ^self + a + b' classified: #(#accessing).
	(model classNamed: #Object) 
		compile: 'foo | a b c | a := InlineMethodFromComponentTest new. b := 1. c := 2. ^a a9: b b9: c'
		classified: #(#accessing).
	self proceedThroughWarning: 
			[refactoring := self createRefactoringWithModel: model andArguments:  
				{ (72 to: 84) . #foo . (model classNamed: #Object)}.
			self setupInlineExpressionFor: refactoring toReturn: false.
			self executeRefactoring: refactoring].
	self assert: ((refactoring model classNamed: #Object) parseTreeFor: #foo) 
			equals: (self 
						parseMethod: 'foo | a b c | a := InlineMethodFromComponentTest new. b := 1. c := 2. ^a + b + c')
]

{ #category : #tests }
RBInlineMethodFromComponentParametrizedTest >> testModelInlineMethodWithSameVariableNames1 [
	| class refactoring |
	model := RBClassModelFactory rbNamespace new.
	class := model classNamed: #Rectangle.
	class 
		compile: 'rectangleRelativeTo: aRectangle ^self origin extent: aRectangle extent'
		classified: #(#accessing).
	(model classNamed: #Object) 
		compile: 'foo | aRectangle temp | aRectangle := 0@0 corner: 1@1. temp := aRectangle. ^aRectangle rectangleRelativeTo: temp'
		classified: #(#accessing).
	self proceedThroughWarning: 
			[refactoring := self createRefactoringWithModel: model andArguments:  
				 { (77 to: 112) . #foo . (model classNamed: #Object)}.
			self setupInlineExpressionFor: refactoring toReturn: false.
			self setupImplementorToInlineFor: refactoring toReturn: class.
			self executeRefactoring: refactoring].
	self assert: ((refactoring model classNamed: #Object) parseTreeFor: #foo) 
			equals: (self 
						parseMethod: 'foo | aRectangle temp | aRectangle := 0@0 corner: 1@1. temp := aRectangle. ^aRectangle origin extent: temp extent')
]

{ #category : #tests }
RBInlineMethodFromComponentParametrizedTest >> testModelInlineMethodWithSameVariableNames2 [
	| class refactoring |
	model := RBClassModelFactory rbNamespace new.
	class := model classNamed: self class name.
	class compile: 'a9: a b9: b ^self + a + b' classified: #(#accessing).
	(model classNamed: #Object) 
		compile: 'foo | a b c | a := InlineMethodFromComponentTest new. b := 1. c := 2. ^c a9: b b9: a'
		classified: #(#accessing).
	self proceedThroughWarning: 
			[refactoring := self createRefactoringWithModel: model andArguments:  
				{ (72 to: 84) . #foo . (model classNamed: #Object) }.
			self setupInlineExpressionFor: refactoring toReturn: false.
			self executeRefactoring: refactoring].
	self assert: ((refactoring model classNamed: #Object) parseTreeFor: #foo) 
				equals: (self 
						parseMethod: 'foo | a b c | a := InlineMethodFromComponentTest new. b := 1. c := 2. ^c + b + a')
]
