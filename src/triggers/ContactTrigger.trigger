trigger ContactTrigger on Contact (before insert, before update, after insert, after update) {

    if (Trigger.isBefore) {
        if(Trigger.isInsert) {
            // Process users that enabled 2FA.
            for (Contact cntRecord : Trigger.new) {
                if (cntRecord.enable2FA__c && cntRecord.Phone != null) {
                    cntRecord.tmpTwilioCode__c = AppUtils.getRandomUniqueString(10);
                }
            }
        }

        if(Trigger.isUpdate) {
            // Process contacts that recently enabled 2FA.
            for (Contact cntRecord : Trigger.new) {
                if (cntRecord.enable2FA__c && !Trigger.oldMap.get(cntRecord.Id).enable2FA__c) {
                    cntRecord.tmpTwilioCode__c = AppUtils.getRandomUniqueString(10);
                }
            }
        }
    }

    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        // Get the record ids that need to receive an SMS.
        Set<Id> twilioContacts = new Set<Id>();
        for (Contact cntRecord : Trigger.new) {
            if (cntRecord.tmpTwilioCode__c != null) {
                twilioContacts.add(cntRecord.Id);
            }
        }

        if(!twilioContacts.isEmpty()) {
            TwilioUtils.sendSMSAsync(twilioContacts);
        }
    }

}