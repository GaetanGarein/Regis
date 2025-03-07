"
Description
--------------------

Principal Class To Create tabs
"
Class {
	#name : #ERContainerTab,
	#superclass : #ERTab,
	#instVars : [
		'controller',
		'callback',
		'mofidyUserForm',
		'formWithoutBasicInfo',
		'formRegister',
		'attenteeRegisterForm',
		'formApplyReductionTicket',
		'formMofidyAffiliation',
		'table',
		'newUsersTable',
		'formAward',
		'formTalk',
		'formGroupInfo'
	],
	#category : #'ESUGApp-View-Tab'
}

{ #category : #'as yet unclassified' }
ERContainerTab class >> on: anAttendee withContent: aContent [
	| form |
	form := self new.
	form attendee: anAttendee.
	form content: aContent.
	^ form
]

{ #category : #rendering }
ERContainerTab >> alreadyRegisteredAsAttendee [
	^ self session user isAttendee
]

{ #category : #tableBlock }
ERContainerTab >> blockTableAwardsToExecute [
	^ [ :award :html | 
	OrderedCollection new
		add: ([ :att | att nameAward ] value: award);
		add: ([ :att | att submitter userAccount email ] value: award);
		add: ([ :att :aHtml | [ aHtml anchor target: '_blank';
				url: award downloadUrl; 
				with: award downloadUrl ] ] valueWithArguments: {award. html});
		add: ([ :att :aHtml | [ aHtml anchor target: '_blank';
				url: award demoUrl; 
				with: award demoUrl ] ] valueWithArguments: {award. html});
		yourself ]
]

{ #category : #tableBlock }
ERContainerTab >> blockTableTalksToExecute [
	^ [ :talk :html | 
	OrderedCollection new
		add: ([ :att | att title ] value: talk);
		add: ([ :att | att submitter userAccount email ] value: talk);
		add: ([ :att :aHtml | [ aHtml anchor target: '_blank';
				url: talk presentation; 
				with: talk presentation ] ] valueWithArguments: {talk. html});
		yourself ]
]

{ #category : #accessing }
ERContainerTab >> callback [
	^ callback
]

{ #category : #accessing }
ERContainerTab >> callback: anObject [
	callback := anObject
]

{ #category : #actions }
ERContainerTab >> cancel [
	self returnToThePreviousState.
	self updateStateTab: self tabName.
]

{ #category : #actions }
ERContainerTab >> cancel: anObject [
	anObject abortChanges.
	self returnToThePreviousState.
	self updateStateTab: self tabName.
]

{ #category : #rendering }
ERContainerTab >> children [
	^ super children asOrderedCollection copyWithAll: (OrderedCollection new
		add: table;
		yourself); yourself
]

{ #category : #accessing }
ERContainerTab >> content: anObject [
	content := anObject
]

{ #category : #accessing }
ERContainerTab >> controller [
	^ controller
]

{ #category : #accessing }
ERContainerTab >> controller: anObject [
	controller := anObject
]

{ #category : #deleting }
ERContainerTab >> deleteAward: anAward [
	controller deleteAward: anAward
]

{ #category : #deleting }
ERContainerTab >> deleteTalk: aTalk [
	controller deleteTalk: aTalk
]

{ #category : #actions }
ERContainerTab >> exportInvoiceOf: groupOrAttendee [
	self requestContext respond: [ :response |
		|stream file |
		file := ERPDFInvoice pdfDocOf: groupOrAttendee.
		stream := (RWBinaryOrTextStream on: String new) binary.
		file exportTo: stream.
		response
            contentType: (WAMimeType main: 'application' sub: 'pdf');
            document: stream close; contents ;
            attachmentWithFileName: ('invoice-', groupOrAttendee id asString, '.pdf') ]
]

{ #category : #tableBlock }
ERContainerTab >> filterAwardsInformation [

	^ [ :object :text | 
		((object nameAward) includesSubstring: text caseSensitive: false)
			or: [ ((object submitter userAccount email) includesSubstring: text caseSensitive: false) ] ]
]

{ #category : #tableBlock }
ERContainerTab >> filterTalksInformation [

	^ [ :object :text | 
		((object title) includesSubstring: text caseSensitive: false)
			or: [ ((object submitter userAccount email) includesSubstring: text caseSensitive: false) ] ]
]

{ #category : #initialization }
ERContainerTab >> initializeFormEditAward: anAward [
	formAward := (ERTittledFormView 
							on: anAward 
							withContent: content) title: 'Award'; 
							callback: [:object | self updateAward: object];
							cancelCallback: [self cancel]; initializeForm
]

{ #category : #initialization }
ERContainerTab >> initializeFormEditTalk: aTalk [
	formTalk := (ERTittledFormView 
							on: aTalk 
							withContent: content) title: 'Talk'; 
							callback: [:object | self updateTalk: object];
							cancelCallback: [self cancel]; initializeForm
]

{ #category : #initialization }
ERContainerTab >> initializeFormToGroupManagerFor: anAttendee [

	formWithoutBasicInfo := ERContainerTabs
		formToGroupManagerOn: anAttendee
		withCallback: callback
		content: content.
	content state: formWithoutBasicInfo
]

{ #category : #initialization }
ERContainerTab >> initializeFormWithoutBasicInformationFor: anAttendee [

	formWithoutBasicInfo := ERContainerTabs
		formWithoutBasicInfoOn: anAttendee
		withCallback: callback
		content: content.
	content state: formWithoutBasicInfo
]

{ #category : #initialization }
ERContainerTab >> initializeFormWithoutBasicInformationWithNotGroupFor: anAttendee [
	formWithoutBasicInfo := ERContainerTabs
		formWithoutBasicInfoWithNotGroupOn: anAttendee
		withCallback: callback
		content: content
		conference: controller conference.
	content state: formWithoutBasicInfo
]

{ #category : #initialization }
ERContainerTab >> initializeGroupInformationFormFor: aGroup [

	formGroupInfo := ERContainerTabs
		formGroupInformationFormOn: aGroup
		withCallback: callback
		content: content
		conference: controller conference.
	content state: formGroupInfo
]

{ #category : #initialization }
ERContainerTab >> initializeGroupMemberFormWithoutBasicInformationFor: anAttendee [
	formWithoutBasicInfo := ERContainerTabs
		formWithoutBasicInfoToGroupMemberOn: anAttendee
		withCallback: callback
		content: content.
	content state: formWithoutBasicInfo
]

{ #category : #initialization }
ERContainerTab >> initializeModifyAffiliationForm [
	formMofidyAffiliation := (ERTittledFormView on: controller affiliationInformation 
								withContent: content) title: 'Affiliation Information';
								callback: [:aff | self updateAffiliation: aff on: controller group];
								cancelCallback: [self cancel]; initializeForm. 
	content state: formMofidyAffiliation.
	self updateStateTab: self tabName.
]

{ #category : #initialization }
ERContainerTab >> initializeModifyAffiliationForm: aGroup [
	formMofidyAffiliation := (ERTittledFormView on: aGroup affiliationInformation 
								withContent: content) title: 'Affiliation Information';
								callback: [:aff | self updateAffiliation: aff on: aGroup];
								cancelCallback: [self cancel]; initializeForm. 
	content state: formMofidyAffiliation.
	self updateStateTab: self tabName.
]

{ #category : #updating }
ERContainerTab >> modifyAffiliation: aGroup [
	"self initializeModifyAffiliationForm: aGroup."
	callback := [ self updateRegistrationInformation: aGroup ].
	
	self initializeFormWithoutBasicInformationFor: aGroup.
	self updateStateTab: self tabName.
]

{ #category : #updating }
ERContainerTab >> modifyGroupMemberRegistrationInformation: anAttendee [

	callback := [ self updateRegistrationInformation: anAttendee ].
	self initializeGroupMemberFormWithoutBasicInformationFor: anAttendee.
	self updateStateTab: self tabName.
]

{ #category : #updating }
ERContainerTab >> modifyGroupMemberRegistrationOf: anAttendee [
	anAttendee paymentInformation hasPaid 
		ifFalse:[ self modifyGroupMemberRegistrationInformation: anAttendee ]
		ifTrue: [messageComponent changeToAlertOfError.
			messageComponent errorMessage: 'You can not make modifications after having paid.']
]

{ #category : #updating }
ERContainerTab >> modifyGroupRegistrationInformation: aGroup [

	callback := [ self updateRegistrationInformation: aGroup ].
	self initializeFormWithoutBasicInformationFor: aGroup.
	self updateStateTab: self tabName.
]

{ #category : #updating }
ERContainerTab >> modifyRegistrationInformation: anAttendee [

	callback := [ self updateRegistrationInformation: anAttendee ].
	self initializeFormWithoutBasicInformationFor: anAttendee.
	self updateStateTab: self tabName.
]

{ #category : #updating }
ERContainerTab >> modifyRegistrationInformationOfNotGroupAttendeeLike: anAttendee [

	callback := [ self updateRegistrationInformation: anAttendee ].
	self initializeFormWithoutBasicInformationWithNotGroupFor: anAttendee.
	self updateStateTab: self tabName.
]

{ #category : #updating }
ERContainerTab >> modifyRegistrationOf: anAttendee [

	anAttendee paymentInformation hasPaid 
		ifFalse:[ 
			(anAttendee idGroup)
				ifNil: [ self modifyRegistrationInformationOfNotGroupAttendeeLike: anAttendee ] 
				ifNotNil:  [ self modifyRegistrationInformation: anAttendee ].
			 ]
		ifTrue: [ messageComponent changeToAlertOfError.
			messageComponent errorMessage: 'You can not make modifications after having paid.' ]
]

{ #category : #updating }
ERContainerTab >> modifyUserFormGroup: anUser [
	mofidyUserForm := (ERTittledFormView on: anUser 
								withContent: content) title: 'User';
								callback: [:user | self updateUser: user];
								cancelCallback: [self cancel: anUser]; initializeForm. 
	content state: mofidyUserForm.
	self updateStateTab: self tabName.
]

{ #category : #rendering }
ERContainerTab >> renderContentOn: html [
	html heading level3; with: self title .
	self renderContainerOn: html
]

{ #category : #updating }
ERContainerTab >> toggleTalkAcceptance:  aTalk [
	controller toggleTalkAcceptance: aTalk
]

{ #category : #updating }
ERContainerTab >> updateAffiliation: aff on: aGroup [
	controller updateAffiliation: aff on: aGroup.
	self cancel.
]

{ #category : #updating }
ERContainerTab >> updateAward: anAward [.
	controller updateAward: anAward.
	self cancel
	
]

{ #category : #updating }
ERContainerTab >> updateGroupInformation: aGroup [

	controller updateGroupInformation: aGroup.
	content state: content lastState
]

{ #category : #updating }
ERContainerTab >> updateRegistrationInformation: anAttendee [
	controller updateAttendee: anAttendee.
	content state: content lastState
]

{ #category : #updating }
ERContainerTab >> updateTalk: aTalk [.
	controller updateTalk: aTalk.
	self cancel
	
]

{ #category : #updating }
ERContainerTab >> updateTicket: aTicket from: anAttendee [
	controller applyReductionTicket: aTicket To: anAttendee .
	self returnToThePreviousState. 
	self updateStateTab: self tabName.
]

{ #category : #updating }
ERContainerTab >> updateUser: user [
	|result|
	result := controller updateUser: user.
	(result isMemberOf: ERException) ifTrue: [ result signal ]
	ifFalse: [ self cancel ]
	
]
