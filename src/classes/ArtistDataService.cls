

public class ArtistDataService {

    // Pass in the endpoint to be used using the string url
    public static String getCalloutResponseContents() {

        // Instantiate a new http object
        Http h = new Http();

        // Create httprequest
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://demo3762315.mockable.io/newartists');
        req.setMethod('GET');

        // Send the request, and return a response.
        HttpResponse res = h.send(req);
        // Error handling needed here.
        return res.getBody();
    }

    public static void importArtists() {
        String jsonData = getCalloutResponseContents();

        //Deserialize json
        Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(jsonData);

        //Parse artists
        Map<String, Artist__c> mapArtists = new Map<String, Artist__c>();
        List<Object> artistObjects = getObjectList(dataMap,'artist');

        for(Object objArtist : artistObjects){
            Map<String,Object> mArtist = (Map<String,Object>)objArtist;

            Artist__c artist = new Artist__c();
            artist.Name = getStringValue(mArtist.get('artist-name'), null);

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
            String artistName = getStringValue(mArtist.get('artist-name'), null);

            List<Object> lalbums = (List<Object>)mArtist.get('album');

            for(Object oAlbum : lalbums){
                Map<String,Object> mAlbum = (Map<String,Object>)oAlbum;

                Album__c album = new Album__c();
                album.Name = getStringValue(mAlbum.get('album-name'), null);
                album.Artist__c = mapArtists.get(artistName).Id;
                album.Release_Year__c = getIntegerValue(mAlbum.get('year'), null);

                mapAlbums.put(album.Name, album);
            }
        }

        //Insert albums
        if(mapAlbums.size() > 0){
            Database.insert(mapAlbums.values(), true);
        }

    }


    private static List<Object> getObjectList(Map<String,Object> o, String key){
        if(o != null && o.get(key) != null){
            return (List<Object>)o.get(key);
        }else{
            return new List<Object>();
        }
    }

    private static String getStringValue(Object o, String defaultValue){
        return o != null ? (String)o : defaultValue;
    }

    private static Integer getIntegerValue(Object o, Integer defaultValue){
        return o != null ? Integer.valueOf(o) : defaultValue;
    }
}
