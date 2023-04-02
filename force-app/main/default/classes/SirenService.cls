public without sharing class SirenService {

    public static Boolean checkSiren(String siren) {
        if(siren != null && siren.isNumeric() && siren.length() == 9) {
            return checkCode(siren, 9, true);
        }
        return false;
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean checkSiret(String siret) {
        if(siret != null && siret.isNumeric() && siret.length() == 14) {
            return checkCode(siret, 14, false);
        }
        return false;
    }
    
    private static Boolean checkCode(String code, Integer pos, boolean impair) {
        Integer somme=0;
        String newCode = code.reverse();
        while(pos >= 1) {
            Integer loadedNumber = extractPos(newCode, pos);
            if(impair) {
                somme += loadedNumber;
            } else {
                Integer mult = loadedNumber*2;
                if(mult <= 9) {
                    somme += mult;
                } else {
                    mult -= 10;
                    somme += mult + 1;
                }
            }
            pos -= 1;
            impair = (impair)? false: true;
        }
        Integer res = Math.mod(somme, 10);
        return (res == 0);
    }
    
    private static Integer extractPos(String code, Integer pos) {
        return Integer.valueOf(code.mid(pos-1, 1));
    }
}