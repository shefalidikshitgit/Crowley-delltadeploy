trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert,before Delete) {
	new ContentDocumentLinkTriggerHandler().run();
}