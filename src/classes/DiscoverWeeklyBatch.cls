global with sharing class DiscoverWeeklyBatch implements Database.Batchable<SObject>, Database.Stateful {

    global Database.querylocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('select Id, FirstName, LastName from Contact where isActive__c = true');
    }

    global void execute(Database.BatchableContext BC, Contact[] scope){

        Map<Id, Playlist__c> mapDiscoverWeekly = new Map<Id, Playlist__c>();
        Set<Id> sContacts = new Set<Id>();

        for (Contact ocontact : scope) {
            sContacts.add(ocontact.Id);
            mapDiscoverWeekly.put(ocontact.Id, new Playlist__c(Name = 'Discover Weekly', User__c = ocontact.Id, Description__c = 'Automatically generated playlist.'));
        }

        // Create Playlists
        insert mapDiscoverWeekly.values();

        // Get every user's Play History
        Map<Id, Set<Id>> mapPlayHistory = new Map<Id, Set<Id>>();
        Set<Id> sArtists = new Set<Id>();
        for (Play_History__c ph : [select Id, Artist__c, Song__c, User__c from Play_History__c where User__c in :sContacts]) {

            if (mapPlayHistory.containsKey(ph.User__c)) {
                mapPlayHistory.get(ph.User__c).add(ph.Artist__c);
            } else {
                mapPlayHistory.put(ph.User__c, new Set<Id>{ph.Artist__c});
            }

            sArtists.add(ph.Artist__c);
        }

        Map<Id, Set<Id>> mapRelatedArtists = new Map<Id, Set<Id>>();
        Set<Id> allRelatedArtists = new Set<Id>();

        // Get related artists
        for (Related_Artists__c ra : [select Artist_A__c, Artist_B__c from Related_Artists__c where Artist_A__c in :sArtists]) {

            if (mapRelatedArtists.containsKey(ra.Artist_A__c)) {
                mapRelatedArtists.get(ra.Artist_A__c).add(ra.Artist_B__c);
            } else {
                mapRelatedArtists.put(ra.Artist_A__c, new Set<Id>{ra.Artist_B__c});
            }
            allRelatedArtists.add(ra.Artist_B__c);
        }

        //Get new artists for users
        Map<Id, Set<Id>> mapUserNewArtist = new Map<Id, Set<Id>>();
        for (Id userId : mapPlayHistory.keySet()) {

            //get current artists per user and iterate
            for(Id currentArtist : mapPlayHistory.get(userId)){

                if (mapUserNewArtist.containsKey(userId)) {
                    mapUserNewArtist.get(userId).addAll(mapRelatedArtists.get(currentArtist));
                } else {
                    mapUserNewArtist.put(userId, mapRelatedArtists.get(currentArtist));
                }
            }
        }

        Map<Id, List<Id>> mapSongsPerArtist = new Map<Id, List<Id>>();
        //Query for songs
        Set<Integer> rankSet = new Set<Integer>{1,2,3,4,5};
        for (Song__c song : [select Id,
                                    Album__r.Artist__c,
                                    Order__c
                                    from Song__c
                                    where Album__r.Artist__c in :allRelatedArtists
                                    and Rank__c in :rankSet]) {

            if (mapSongsPerArtist.containsKey(song.Album__r.Artist__c)) {
                mapSongsPerArtist.get(song.Album__r.Artist__c).add(song.Id);
            } else {
                mapSongsPerArtist.put(song.Album__r.Artist__c, new List<Id>{song.Id});
            }

        }

        List<Playlist_Item__c> lPlaylistItems = new List<Playlist_Item__c>();
        //iterate over new artist for users
        for (Id userId : mapUserNewArtist.keySet()) {
            //iterate over new artists
            for (Id artistId : mapUserNewArtist.get(userId)) {
                Playlist_Item__c pli = new Playlist_Item__c();
                Integer listSize = mapSongsPerArtist.get(artistId).size() - 1;
                Integer randomNum = AppUtils.getRandomIntegerBetween(1,listSize);
                pli.Song__c = mapSongsPerArtist.get(artistId).get(randomNum);
                pli.Playlist__c = mapDiscoverWeekly.get(userId).Id;
                lPlaylistItems.add(pli);
            }
        }

        //create playlist item
        insert lPlaylistItems;
    }

    global void finish(Database.BatchableContext BC){
        // Get info from the current batch job.
        AsyncApexJob currentBatch = [select Id,
                                        Status,
                                        NumberOfErrors,
                                        JobItemsProcessed,
                                        TotalJobItems,
                                        CreatedBy.Email,
                                        CreatedBy.Name,
                                        ExtendedStatus
                                        from AsyncApexJob
                                        where Id = :BC.getJobId()];

        // Email the Batch Job's submitter that the Job is finished.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {currentBatch.CreatedBy.Email});
        mail.setSenderDisplayName('Discover Weekly Process');
        mail.setSubject('Discover Weekly Batch Status: ' + currentBatch.Status);
        mail.setPlainTextBody('Dear ' + currentBatch.CreatedBy.Name + ',\nHere are the Discover Weekly Apex Batch job details:\nTotal Job Items: ' + currentBatch.TotalJobItems + '\nNumber of errors: '+ currentBatch.NumberOfErrors + '\nExtendedStatus: ' + currentBatch.ExtendedStatus);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

}
