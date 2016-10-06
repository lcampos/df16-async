public class ArtistDataService {

    // Pass in the endpoint to be used using the string url
    public static String getCalloutResponseContents() {

        // Instantiate a new http object
        Http h = new Http();

        // Create httprequest
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://demo3762315.mockable.io/newartists'); //This should actually be a custom setting.
        req.setMethod('GET');

        // Send the request, and return a response.
        HttpResponse res = h.send(req);
        // Error handling needed here.
        return res.getBody();
    }
}
