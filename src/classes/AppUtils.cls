public class AppUtils {

    public static String getRandomUniqueString(Integer length){
        return EncodingUtil.base64Encode(crypto.generateAesKey(256)).substring(1,length);
    }

    public static Integer getRandomIntegerBetween(Integer min, Integer max) {
        Integer randomInt = Math.round(Math.random() * ((max - min) + 1) + min);

        if (randomInt < min) {
            randomInt = min;
        } else if (randomInt > max) {
            randomInt = max;
        }
        return randomInt;
    }

    public static List<Object> getObjectList(Map<String,Object> o, String key){
        if(o != null && o.get(key) != null){
            return (List<Object>)o.get(key);
        }else{
            return new List<Object>();
        }
    }

    public static String getStringValue(Object o, String defaultValue){
        return o != null ? (String)o : defaultValue;
    }

    public static Integer getIntegerValue(Object o, Integer defaultValue){
        return o != null ? Integer.valueOf(o) : defaultValue;
    }
}
