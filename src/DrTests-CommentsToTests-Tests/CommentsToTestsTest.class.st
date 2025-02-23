"
A DrTestsUITest is a test class for testing the behavior of DrTests-CommentsToTestsTest 
"
Class {
	#name : #CommentsToTestsTest,
	#superclass : #TestCase,
	#category : #'DrTests-CommentsToTests-Tests-Base'
}

{ #category : #tests }
CommentsToTestsTest >> testCommentWithFailure [
	"(1+3)>>>5"
	
	| docComment commentTestCase |

	docComment := thisContext method ast pharoDocCommentNodes first.
	commentTestCase := CommentTestCase for: docComment.
		
	self should: [commentTestCase testIt] raise: TestFailure
]

{ #category : #tests }
CommentsToTestsTest >> testCommentWithSyntaxError [
	"(1+)>>>5"
	
	| docComment commentTestCase |

	docComment := thisContext method ast pharoDocCommentNodes first.
	commentTestCase := CommentTestCase for: docComment.
	
	self should: [commentTestCase testIt] raise: RuntimeSyntaxError
]

{ #category : #tests }
CommentsToTestsTest >> testErrorComment [
	"(1+3)+6/0>>>4"
	
	| docComment commentTestCase |

	docComment := thisContext method ast pharoDocCommentNodes first.
	commentTestCase := CommentTestCase for: docComment.	
	
	self should: [commentTestCase testIt] raise: Error
]

{ #category : #tests }
CommentsToTestsTest >> testSimpleComment [
	"(1+3)>>>4"
	
	| docComment commentTestCase |

	docComment := thisContext method ast pharoDocCommentNodes first.
	commentTestCase := CommentTestCase for: docComment.
		
	self
		assert: commentTestCase currentValue
		equals: commentTestCase expectedValue
]
