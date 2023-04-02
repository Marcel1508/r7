public class FraisService {
    
    public void updateCodeZoneDeChanlandise(List<Frais__c> frais, Map<Id,Account> accounts){
        List<Id> magasinsIds = new List<Id>();
        List<String> listPostalCode = new List<String>();
        List<String> listCity = new List<String>();
        Map<String,Zone_de_chalandise__c> CityCodePostalAndMagasinVSZoneMap = new Map<String,Zone_de_chalandise__c>();
        Map<Id,String> CityCodePostalAndMagasinVSFraisMap = new Map<Id,String>();
        
        if(!frais.isEmpty() && !accounts.isEmpty()) {
            for(Frais__c fr: frais){
                listPostalCode.add(accounts.get(fr.Account__c).ShippingPostalCode);
                listCity.add(accounts.get(fr.Account__c).ShippingCity);
                magasinsIds.add(fr.Magasin_Associe__c);
            } 
        }
        
        List<Zone_de_chalandise__c> zoneChalandise = [SELECT id, name, Code_postal_text__c, Magasin__c,Libelle_ville__c,Magasin__r.Responsable__c, Code_Chalandise__c 
                                                      FROM Zone_de_chalandise__c 
                                                      WHERE Code_postal_text__c in:listPostalCode
                                                      AND Libelle_ville__c in : listCity
                                                      AND Magasin__c in :magasinsIds];
        
        
        if(!zoneChalandise.isEmpty())    
        {
            CityCodePostalAndMagasinVSZoneMap = getCityCodePostalAndMagasinVSZoneMap(zoneChalandise);
            CityCodePostalAndMagasinVSFraisMap = getCityCodePostalAndMagasinVSFraisMap(frais,accounts);
            if(CityCodePostalAndMagasinVSZoneMap.isEmpty() || CityCodePostalAndMagasinVSFraisMap.isEmpty())
            {
                for(Frais__c fr: frais){
                    fr.Code_Zone_de_chalandise__c='5';
                } 
            }else{
                Zone_de_chalandise__c z = new Zone_de_chalandise__c();
                for(Frais__c fr: frais)
                { 
                    if(CityCodePostalAndMagasinVSFraisMap.get(fr.id)!= null)
                    {
                        if(CityCodePostalAndMagasinVSZoneMap.get(CityCodePostalAndMagasinVSFraisMap.get(fr.id))!= null)
                        {
                            z = CityCodePostalAndMagasinVSZoneMap.get(CityCodePostalAndMagasinVSFraisMap.get(fr.id));
                            fr.Code_Zone_de_chalandise__c = z.Code_Chalandise__c;
                        }else
                        {
                            fr.Code_Zone_de_chalandise__c = '5';
                        }
                    }else
                    {
                        fr.Code_Zone_de_chalandise__c = '5';
                    }
                     
                }
                  
            }
            
        }else
        {
            for(Frais__c fr: frais){
                fr.Code_Zone_de_chalandise__c='5';
            } 
        }
    }
    
    public  Map<String,Zone_de_chalandise__c> getCityCodePostalAndMagasinVSZoneMap(List<Zone_de_chalandise__c> ZoneChalandises){
        Map<String,Zone_de_chalandise__c> mapCityCodeMagasinVsZoneChalandise=new Map<String,Zone_de_chalandise__c>();
        for(Zone_de_chalandise__c zone :ZoneChalandises){
            String cityPostalMagasinCompositeKey = zone.Libelle_ville__c.toUpperCase()+zone.Code_postal_text__c+zone.Magasin__c;
            mapCityCodeMagasinVsZoneChalandise.put(cityPostalMagasinCompositeKey, zone);
            
        }
        return mapCityCodeMagasinVsZoneChalandise;
    }
    
    public  Map<Id,String> getCityCodePostalAndMagasinVSFraisMap(List<Frais__c> frais, Map<Id,Account> accounts ){
        Map<Id,String> mapCityCodeMagasinVsFrais=new Map<Id,String>();
        String CityCodePostalAndMagasin;
        if(frais != null && accounts != null && !frais.IsEmpty() && !accounts.isEmpty()){
            for(Frais__c fr :frais){
                if(accounts.get(fr.Account__c) != null && accounts.get(fr.Account__c).ShippingCity != null && accounts.get(fr.Account__c).ShippingPostalCode !=null && fr.Magasin_Associe__c !=null ){
                    CityCodePostalAndMagasin = accounts.get(fr.Account__c).ShippingCity.toUpperCase()+accounts.get(fr.Account__c).ShippingPostalCode+fr.Magasin_Associe__c;
                    mapCityCodeMagasinVsFrais.put(fr.id,CityCodePostalAndMagasin ); 
                }          
            }
        }
        return mapCityCodeMagasinVsFrais;
    }
    
}