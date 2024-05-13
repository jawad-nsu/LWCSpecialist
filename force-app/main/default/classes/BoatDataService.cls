public with sharing class BoatDataService {
    @AuraEnabled(cacheable=true)
    public static List<BoatType__c> getBoatTypes() {
        return [
            SELECT Name, Id
            FROM BoatType__c
            WITH SECURITY_ENFORCED
            ORDER BY Name
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Boat__c> getBoats(String boatTypeId) {
        String query = 'SELECT Name, Description__c, Picture__c, Price__c, Geolocation__Latitude__s, Geolocation_Longitude__s, BoatType__c, BoatType__r.Name, Contact__r.Name, Length__c FROM Boat__c';
        // If boatTypeId is provided, filter the boats by the boatTypeId
        if (String.isNotBlank(boatTypeId)) {
            query += ' WHERE BoatType__c = :boatTypeId';
        }
        return Database.query(query);
    }

    @AuraEnabled(cacheable=true)
    public static List<Boat__c> getSimilarBoats(Id boatId, String similarBy) {
        List<Boat__c> similarBoats = new List<Boat__c>();
        List<Boat__c> parentBoat = [
            SELECT Id, Price__c, Length__c, BoatType__c, BoatType__r.Name 
            FROM Boat__c 
            WHERE Id = :boatId 
            WITH SECURITY_ENFORCED];

        // If the parent boat is not found, return an empty list for similar boats
        if (parentBoat.isEmpty()) {
            return similarBoats;
        }

        // Return all the boats that are similar TYPE to the parent boat TYPE, excluding the parent boat
        if (similarBy == 'Type') {
            similarBoats = [
                SELECT Id, Contact__r.Name, Name, BoatType__c, BoatType__r.Name, Length__c, Picture__c, Price__c, Year_Built__c
                FROM Boat__c
                WHERE Id != :parentBoat.get(0).Id
                AND (BoatType__c = :parentBoat.get(0).BoatType__c)
                WITH SECURITY_ENFORCED
                ORDER BY Price__c, Length__c, Year_Built__c
            ];
           
        } else if (similarBy == 'Price') {
            // return all the boats that are similar PRICE to the parent boat PRICE, excluding the parent boat
            // Price range is 50% less or more than the parent boat price
            similarBoats = [
                SELECT Id, Contact__r.Name, Name, BoatType__c, BoatType__r.Name, Length__c, Picture__c, Price__c, Year_Built__c
                FROM Boat__c
                WHERE Id != :parentBoat.get(0).Id
                AND (Price__c >= :parentBoat.get(0).Price__c / 1.5)
                AND (Price__c <= :parentBoat.get(0).Price__c * 1.5)
                WITH SECURITY_ENFORCED
                ORDER BY Price__c, Length__c, Year_Built__c
            ];
        } else if (similarBy == 'Length') {
            // return all the boats that are similar LENGTH to the parent boat LENGTH, excluding the parent boat
            // Length range is 50% less or more than the parent boat length
            similarBoats = [
                SELECT Id, Contact__r.Name, Name, BoatType__c, BoatType__r.Name, Length__c, Picture__c, Price__c, Year_Built__c
                FROM Boat__c
                WHERE Id != :parentBoat.get(0).Id
                AND (Length__c >= :parentBoat.get(0).Length__c / 1.5)
                AND (Length__c <= :parentBoat.get(0).Length__c * 1.5)
                WITH SECURITY_ENFORCED
                ORDER BY Length__c, Price__c, Year_Built__c
            ];
        }
        return similarBoats;
    }

    @AuraEnabled
    public static List<BoatReview__c> getAllReviews(Id boatId) {
        return [
            SELECT
                Id,
                Name,
                Comment__c,
                Rating__c,
                LastModifiedDate,
                CreatedDate,
                CreatedBy.Name,
                CreatedBy.SmallPhotoUrl,
                CreatedBy.CompanyName
            FROM
                BoatReview__c
            WHERE
                Boat__c =:boatId
            WITH SECURITY_ENFORCED
            ORDER BY
                CreatedDate DESC
        ];
    }

    @AuraEnabled(cacheable=true)
    public static String getBoatsByLocation(Decimal latitude, Decimal longitude, String boatTypeId) {
        // Query to get the boats based on the location
        // The query uses the DISTANCE function to calculate the distance between the boat location and the given location
        // The query returns the top 10 boats based on the distance
        // if boatTypeId is not provided, the query returns all the boats
        String query = 'SELECT Name, Geolocation__Latitude__s, Geolocation__Longitude__s FROM Boat__c ';
        if (String.isNotBlank(boatTypeId)) {
            query += 'WHERE BoatType__c = :boatTypeId ';
        }
        query += ' WITH SECURITY_ENFORCED ORDER BY DISTANCE(Geolocation__c, GEOLOCATION(:latitude, :longitude), \'mi\') LIMIT 10';
        return JSON.serialize(Database.query(query));
    }

    @AuraEnabled
    public static String updateBoatList(Object data){
        // Deserialize the data to a list of Boat__c
        List<Boat__c> boatsForUpdate = (List<Boat__c>) JSON.deserialize(
            JSON.serialize(data),
            List<Boat__c>.class
        );
        
        update boatsForUpdate;
        return 'Success: Boats updated successfully';
    }
}
