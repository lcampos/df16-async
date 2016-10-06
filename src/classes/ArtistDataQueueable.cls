public class ArtistDataQueueable implements Queueable, Database.AllowsCallouts {

    public void execute(QueueableContext context) {
        //Make a callout to REST service for new Artist data.
        String jsonData = ArtistDataService.getCalloutResponseContents();

        //Deserialize json response.
        Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(jsonData);

        //Parse artist data.
        Map<String, Artist__c> mapArtists = new Map<String, Artist__c>();
        List<Object> artistObjects = AppUtils.getObjectList(dataMap,'artist');

        for(Object objArtist : artistObjects){
            Map<String,Object> mArtist = (Map<String,Object>)objArtist;

            Artist__c artist = new Artist__c();
            artist.Name = AppUtils.getStringValue(mArtist.get('artist-name'), null);

            mapArtists.put(artist.Name, artist);

        }

        //Insert artists
        if(mapArtists.size() > 0){
            Database.insert(mapArtists.values(), true);
        }

        //Parse albums per artist
        Map<String, Album__c> mapAlbums = new Map<String, Album__c>();
        for(Object objArtist : artistObjects){
            Map<String, Object> mArtist = (Map<String, Object>)objArtist;
            String artistName = AppUtils.getStringValue(mArtist.get('artist-name'), null);

            List<Object> lalbums = (List<Object>)mArtist.get('album');

            for(Object oAlbum : lalbums){
                Map<String,Object> mAlbum = (Map<String,Object>)oAlbum;

                Album__c album = new Album__c();
                album.Name = AppUtils.getStringValue(mAlbum.get('album-name'), null);
                album.Artist__c = mapArtists.get(artistName).Id;
                album.Release_Year__c = AppUtils.getIntegerValue(mAlbum.get('year'), null);

                mapAlbums.put(album.Name, album);
            }
        }

        //Insert albums
        if(mapAlbums.size() > 0){
            Database.insert(mapAlbums.values(), true);
        }
    }

    /*ID jobID = System.enqueueJob(new ArtistDataQueueable());
    List<AsyncApexJob> queryQueue = [SELECT Id, Status, NumberOfErrors FROM AsyncApexJob WHERE Id = :jobID];
    System.debug('---- queryQueue = ' +queryQueue);*/
}
