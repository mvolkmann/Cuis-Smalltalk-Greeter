'From Cuis7.3 [latest update: #6991] on 25 January 2025 at 8:08:46 am'!
'Description '!
!provides: 'Greeter' 1 2!
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


!Greeter methodsFor: 'initialization' stamp: 'RMV 1/25/2025 08:04:47'!
initialize
	| column greetingLabel nameInput row |
	
	super initialize.
	
	self setLabel: 'Greeter'.
	
	nameInput := TextModelMorph withModel: (TextModel withText: '').
	nameInput emptyTextDisplayMessage: 'Enter your name'.
	
	"Don't warn the user that changes have not been saved when the window is closed."
	nameInput askBeforeDiscardingEdits: false.
	
	greetingLabel := LabelMorph contents: ''.
		
	"Update greetingLabel on any keystroke in nameInput."
	nameInput keystrokeAction: [ :event |
		| name |
		name := nameInput text.
		greetingLabel contents: (name isEmpty
			ifTrue: ''
			ifFalse: [ 'Hello ', name, '!!' ]
		).
	].
	
	row := LayoutMorph newRow.
	row separation: 10. "between child morphs; defaults to 0"
	row padding: 0. "must set after separation"
	row
		addMorph: (LabelMorph contents: 'Name:');
		addMorph: nameInput proportionalWidth: 1. "fills row"

	column := self layoutMorph.
	column separation: 10. "between child morphs; defaults to 0"
	column padding: 10. "around window edges; must set after separation"
	column
		addMorph: row fixedHeight: 0; "to use minimum height that fits row children"
		addMorph: greetingLabel.
	
	"To left align all child morphs of column ...
	column submorphs do: [ :morph | morph layoutSpec offAxisEdgeWeight: #leftOrTop ]."
! !

!Greeter methodsFor: 'GUI building' stamp: 'RMV 1/25/2025 07:51:01'!
initialExtent
	"Set the size of the window. This approach is good for windows with known size.
	See the open method for sizing the window based on its contents."

	^ 0@0
! !

!Greeter class methodsFor: 'as yet unclassified' stamp: 'RMV 1/25/2025 07:47:38'!
open
	| extent window |
	
	window := self new.
	window openInWorld.
	
	"Set window size to the smallest size that contains its submorphs.
	This must done AFTER the window is opened."
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
