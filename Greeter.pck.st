'From Cuis7.3 [latest update: #7012] on 28 January 2025 at 7:54:38 pm'!
'Description '!
!provides: 'Greeter' 1 9!
SystemOrganization addCategory: #Greeter!


!classDefinition: #Greeter category: #Greeter!
SystemWindow subclass: #Greeter
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Greeter'!
!classDefinition: 'Greeter class' category: #Greeter!
Greeter class
	instanceVariableNames: ''!


!Greeter methodsFor: 'initialization' stamp: 'RMV 1/28/2025 19:54:30'!
initialize
	| ageInput ageRow column greetingLabel handleTab nameInput nameRow |
	
	super initialize.
	
	self setLabel: 'Greeter'.
	
	handleTab := [ :evt |
		| isTab |
		
		isTab := evt keyValue = 9.
		isTab ifTrue: [
			evt buttons = 8 "shift key"
				ifTrue: [ evt hand keyboardFocusPrevious ]
				ifFalse: [ evt hand keyboardFocusNext ]
		].
		isTab.
	].

	greetingLabel := LabelMorph contents: ''.
		
	nameInput := TextModelMorph withModel: (TextModel withText: '').
	nameInput emptyTextDisplayMessage: 'Enter your name'.
	
	"Update greetingLabel on any keystroke in nameInput."
	nameInput keystrokeAction: [ :evt |
		| name |
		
		handleTab value: evt ::
			ifFalse: [
				name := nameInput text.
				greetingLabel contents: (name isEmpty
					ifTrue: ''
					ifFalse: [ 'Hello ', name, '!!' ]
				).
			]
	].
	
	ageInput := TextModelMorph withModel: (TextModel withText: '').
	ageInput keystrokeAction: handleTab.

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

!InnerTextMorph methodsFor: '*Greeter' stamp: 'RMV 1/28/2025 19:46:02'!
processKeystrokeEvent: evt
	| action |

	(acceptOn = #enter and: [evt isReturnKey]) ifTrue: [^ self acceptContents].

	self pauseBlinking.
	
	"Return - check for special action"
	evt isReturnKey ifTrue: [	
		action := self crAction.
		action ifNotNil: [ ^action value ] ].
	
	"Esc - check for special action"
	evt isEsc ifTrue: [			
		action := self escAction.
		action ifNotNil: [ ^action value ] ].
	
	"The Greeter package added this check for the tab key."
	evt keyValue = 9 ifFalse: [
		self handleInteraction: [ editor processKeystrokeEvent: evt ]
	].
	(owner is: #ScrollPane) ifTrue: [
		owner scrollSelectionIntoView ].

	"Only accept (on any) if we have unaccepted edits, otherwise the morph will flash."
	(hasUnacceptedEdits and: [ acceptOn == #any ]) ifTrue: [ self acceptContents ].! !
