Class {
	#name : #RBPushDownMethodTransformation,
	#superclass : #RBCompositeMethodTransformation,
	#instVars : [
		'selectors',
		'classes'
	],
	#category : #'Refactoring2-Transformations-Model-Migrated'
}

{ #category : #api }
RBPushDownMethodTransformation class >> model: aRBNamespace pushDown: selectorCollection from: aClass [
	^ self new
		model: aRBNamespace;
		pushDown: selectorCollection from: aClass;
		yourself
]

{ #category : #api }
RBPushDownMethodTransformation class >> model: aRBNamespace pushDown: selectorCollection from: aClass in: classes [
	^ self new
		model: aRBNamespace;
		pushDown: selectorCollection from: aClass in: classes;
		yourself
]

{ #category : #api }
RBPushDownMethodTransformation class >> pushDown: selectorCollection from: aClass [
	^ self new pushDown: selectorCollection from: aClass
]

{ #category : #api }
RBPushDownMethodTransformation class >> pushDown: selectorCollection from: aClass in: classes [
	^ self new pushDown: selectorCollection from: aClass in: classes
]

{ #category : #accessing }
RBPushDownMethodTransformation >> allClasses [

	^ classes ifNil: [ class subclasses ]
]

{ #category : #converting }
RBPushDownMethodTransformation >> asRefactoring [

	^ super asRefactoring
		delegatesPreconditions: false;
		yourself
]

{ #category : #executing }
RBPushDownMethodTransformation >> buildTransformations [

	^ self pushDownSelectors , {self removeSelectors}
]

{ #category : #accessing }
RBPushDownMethodTransformation >> classes: aCollection [
	classes := aCollection collect: [ :cls | 
		self model classObjectFor: cls.
	]
]

{ #category : #preconditions }
RBPushDownMethodTransformation >> preconditions [

	| condition |
	condition := selectors
		             inject: self emptyCondition
		             into: [ :cond :each | 
			             cond & (RBCondition definesSelector: each in: class)
			             &
			             (RBCondition subclassesOf: class referToSelector: each)
				             not ].
	^ condition & (RBCondition isAbstractClass: class)
]

{ #category : #transforming }
RBPushDownMethodTransformation >> pushDown: aSelector [

	| code protocols refactoring |
	code := class sourceCodeFor: aSelector.
	protocols := class protocolsFor: aSelector.
	refactoring := RBExpandReferencedPoolsTransformation
		               model: self model
		               forMethod: (class parseTreeFor: aSelector)
		               fromClass: class
		               toClasses: self allClasses.
	^ {refactoring}, (self allClasses select: [ :each | (each directlyDefinesMethod: aSelector) not ] 
		thenCollect: [ :each |
				RBAddMethodTransformation
				model: self model
				sourceCode: code 
				in: each 
				withProtocols: protocols ])
]

{ #category : #api }
RBPushDownMethodTransformation >> pushDown: selectorCollection from: aClass [
	class := self model classObjectFor: aClass.
	selectors := selectorCollection
]

{ #category : #api }
RBPushDownMethodTransformation >> pushDown: selectorCollection from: aClass in: aCollection [
	class := self model classObjectFor: aClass.
	selectors := selectorCollection.
	self classes: aCollection.
]

{ #category : #transforming }
RBPushDownMethodTransformation >> pushDownSelectors [
	^ selectors flatCollect: [:each | self pushDown: each].
]

{ #category : #transforming }
RBPushDownMethodTransformation >> removeSelectors [
	^ RBRemoveMethodTransformation 
		model: self model
		selectors: selectors
		from: class
]

{ #category : #printing }
RBPushDownMethodTransformation >> storeOn: aStream [
	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream
		nextPutAll: ' pushDown: ';
		nextPutAll: selectors asString;
		nextPutAll: ' from: ';
		nextPutAll: class name;
		nextPutAll: ' in: '.
	(classes collect: [ :e | e name ]) storeOn: aStream.
	aStream nextPut: $)
]

{ #category : #accessing }
RBPushDownMethodTransformation >> targetClass [
	^ class
]
