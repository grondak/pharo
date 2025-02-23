Extension { #name : #Set }

{ #category : #'*STON-Core' }
Set >> stonPostReferenceResolution [
	"When references were resolved in me, the hash of my elements might have changed.
	Check if I am still healthy and rehash me if not."
	
	self isHealthy ifFalse: [ self rehash ]
]
