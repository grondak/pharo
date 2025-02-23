"
A minified version of the DrTest tool.
"
Class {
	#name : #MiniDrTests,
	#superclass : #AbstractDrTestsPresenter,
	#instVars : [
		'startButton'
	],
	#category : #'DrTests-Spec'
}

{ #category : #layout }
MiniDrTests class >> defaultLayout [
	^ SpBoxLayout newTopToBottom
		add: (SpBoxLayout newLeftToRight
				add: #switchButton;
				yourself)
		expand: false
		fill: true
		padding: 1;
		add: #startButton;
		yourself
]

{ #category : #accessing }
MiniDrTests >> currentPlugin: anObject [

	currentPlugin := anObject
]

{ #category : #accessing }
MiniDrTests >> evaluateBackgroundColor [

	^ pluginResult backgroundColor
]

{ #category : #'private - initialization' }
MiniDrTests >> initializeButtons [
	super initializeButtons.

	startButton := self newButton.

	startButton
		label: 'run';
		icon: (self iconNamed: #smallUpdate);
		color: (Color gray).
	switchButton
		label: 'Maximize'.
		
	startButton action: [ self runPlugin ]
]

{ #category : #initialization }
MiniDrTests >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: self title;
		initialExtent: 200 @ 200
]

{ #category : #accessing }
MiniDrTests >> startButton [
	^ startButton
]

{ #category : #'private - actions' }
MiniDrTests >> switchToDrTest [

	DrTests
		reloadConfiguration: testsConfiguration
		withResults: pluginResult
		andPlugin: currentPlugin
]

{ #category : #actions }
MiniDrTests >> switchUI [

	super switchUI.
	self switchToDrTest
]

{ #category : #accessing }
MiniDrTests >> title [

	^ 'MiniDrTests - ' , currentPlugin pluginName
]

{ #category : #updating }
MiniDrTests >> updateUI [

	super updateUI.
	startButton color: self evaluateBackgroundColor.
	startButton label: pluginResult summarizeInfo
]

{ #category : #initialization }
MiniDrTests >> updateWithResults: results [
	self pluginResult: results.
	self updateUI
]
