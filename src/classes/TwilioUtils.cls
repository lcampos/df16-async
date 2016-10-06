public class TwilioUtils {

    // Call async from triggers, etc, where callouts are not permitted.
    @future(callout=true)
    public static void sendSMSAsync(Set<Id> contactIDs) {
        List<Contact> contacts = [select Id,
                                        FirstName,
                                        Phone,
                                        tmpTwilioCode__c
                                        from Contact
                                        where Id in :contactIDs];

        for (Contact cntRec : contacts) {
            String results = sendSMS(cntRec);

            if (results != 'error') {
                cntRec.tmpTwilioCode__c = '';
            }
        }

        update contacts;
    }

    // Call from controllers, etc, for immediate processing
    public static String sendSMS(Contact clientData) {
        TwilioRestClient restClient = TwilioAPI.getDefaultClient();

        Map<String,String> twilioSMSPayload = new Map<String,String>();
        twilioSMSPayload.put('To', clientData.Phone);
        twilioSMSPayload.put('From', TwilioConfig__c.getOrgDefaults().Phone__c);
        twilioSMSPayload.put('Body', 'Hi ' + clientData.FirstName + ', use access code ' + clientData.tmpTwilioCode__c + ' to verify your phone.');

        TwilioMessage message = restClient.getAccount().getMessages().create(twilioSMSPayload);
        return message.getStatus();
    }
}