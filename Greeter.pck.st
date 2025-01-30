'From Cuis7.3 [latest update: #7041] on 30 January 2025 at 3:46:08 pm'!
'Description '!
!provides: 'Greeter' 1 23!
SystemOrganization addCategory: #Greeter!


!classDefinition: #TextInputMorph category: #Greeter!
TextModelMorph subclass: #TextInputMorph
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Greeter'!
!classDefinition: 'TextInputMorph class' category: #Greeter!
TextInputMorph class
	instanceVariableNames: ''!

!classDefinition: #Greeter category: #Greeter!
SystemWindow subclass: #Greeter
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Greeter'!
!classDefinition: 'Greeter class' category: #Greeter!
Greeter class
	instanceVariableNames: ''!

!classDefinition: #InnerTextNoTabMorph category: #Greeter!
InnerTextMorph subclass: #InnerTextNoTabMorph
	instanceVariableNames: 'changeBlock'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Greeter'!
!classDefinition: 'InnerTextNoTabMorph class' category: #Greeter!
InnerTextNoTabMorph class
	instanceVariableNames: ''!


!TextInputMorph methodsFor: 'as yet unclassified' stamp: 'RMV 1/30/2025 15:46:04'!
initialize

	super initialize.
	
	self keystrokeAction: [ :evt |
		evt keyValue = 9 ifTrue: [ "tab key"
			evt buttons = 8 "shift key"
				ifTrue: [ evt hand keyboardFocusPrevious ]
				ifFalse: [ evt hand keyboardFocusNext ]
		]
	].! !

!TextInputMorph methodsFor: 'as yet unclassified' stamp: 'RMV 1/30/2025 15:06:01'!
innerMorphClass
	^InnerTextNoTabMorph! !

!TextInputMorph methodsFor: 'as yet unclassified' stamp: 'RMV 1/30/2025 15:44:24'!
onChange: aBlock

	self innerTextMorph onChange: aBlock! !

!Greeter methodsFor: 'initialization' stamp: 'RMV 1/30/2025 15:42:13'!
initialize
	| ageInput ageRow column greetingLabel nameInput nameRow |
	
	super initialize.
		
	self setLabel: 'Greeter'.
	
	greetingLabel := LabelMorph contents: ''.
		
	nameInput := TextInputMorph withModel: (TextModel withText: '').
	nameInput emptyTextDisplayMessage: 'Enter your name'.
	
	"Update greetingLabel on any keystroke in nameInput."
	"TODO: Change this to run the block on any change,
	not individual keystrokes, because TextInputMorph initialize
	needs to listen to the keystrokes!!"
	nameInput onChange: [
		| name |
		
		name := nameInput text.
		greetingLabel contents: (name isEmpty
			ifTrue: ''
			ifFalse: [ 'Hello ', name, '!!' ]
		).
	].
	
	ageInput := TextInputMorph withModel: (TextModel withText: '').

	"Don't warn the user that changes have not been saved when the window is closed."
	nameInput askBeforeDiscardingEdits: false.
	ageInput askBeforeDiscardingEdits: false.
	
	nameRow := LayoutMorph newRow.
	nameRow separation: 10. "between child morphs; defaults to 0"
	nameRow padding: 0. "must set after separation"
	nameRow
		addMorph: (LabelMorph contents: 'Name:');
		addMorph: nameInput proportionalWidth: 1. "fills row"

	ageRow := LayoutMorph newRow.
	ageRow separation: 10.
	ageRow padding: 0.
	ageRow
		addMorph: (LabelMorph contents: 'Age:');
		addMorph: ageInput proportionalWidth: 1. "fills row"

	column := self layoutMorph.
	column separation: 10. "between child morphs; defaults to 0"
	column padding: 10. "around window edges; must set after separation"
	column
		addMorph: nameRow fixedHeight: 0; "to use minimum height that fits row children"
		addMorph: ageRow fixedHeight: 0; "to use minimum height that fits row children"
		addMorph: greetingLabel.
	
	"To left align all child morphs of column ...
	column submorphs do: [ :morph | morph layoutSpec offAxisEdgeWeight: #leftOrTop ]."! !

!Greeter class methodsFor: 'as yet unclassified' stamp: 'RMV 1/25/2025 08:37:51'!
open
	| extent window |
	
	window := self new.
	window openInWorld.
	
	"Set window size to the smallest height that contains its submorphs.
	This must be done AFTER the window is opened."
	extent := window layoutMorph minimumExtent.
	window morphExtent: 300 @ extent y.! !

!Greeter class methodsFor: 'as yet unclassified' stamp: 'RMV 1/25/2025 07:57:49'!
worldMenuOptions
	^`{
		{
			#submenuOf -> TheWorldMenu openLabel.
			#itemGroup -> 10.
			#itemOrder -> 42.
			#label -> 'Greeter'.
			#object -> Greeter.
			#selector -> #open.
			#icon -> #chatIcon.
			#balloonText -> 'Opens a window where you can greet yourself'.
		} asDictionary
	}`! !

!InnerTextNoTabMorph methodsFor: 'as yet unclassified' stamp: 'RMV 1/30/2025 15:42:37'!
onChange: aBlock

	changeBlock := aBlock! !

!InnerTextNoTabMorph methodsFor: 'as yet unclassified' stamp: 'RMV 1/30/2025 15:41:24'!
processKeystrokeEvent: evt

	(acceptOn = #enter and: [evt isReturnKey]) ifTrue: [^ self acceptContents].

	self pauseBlinking.

	"Return - check for special action"
	evt isReturnKey ifTrue: [
		self crAction ifNotNil: [ :action |
			^action value ]].

	"Esc - check for special action"
	evt isEsc ifTrue: [			
		self escAction ifNotNil: [ :action |
			^action value ]].

	evt keyValue = 9 ifFalse: [ "skips processing tab key"
		self handleInteraction: [
			editor processKeystrokeEvent: evt.
			changeBlock ifNotNil: [ changeBlock value ].
		].
	].
	
	(owner is: #ScrollPane) ifTrue: [
		owner scrollSelectionIntoView ].

	"Only accept (on any) if we have unaccepted edits, otherwise the morph will flash."
	(hasUnacceptedEdits and: [ acceptOn == #any ]) ifTrue: [ self acceptContents ].! !
