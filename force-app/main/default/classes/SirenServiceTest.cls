@isTest
public class SirenServiceTest {

    @isTest
    private static void testCheckSiren() {
        system.assertEquals(false, SirenService.checkSiren('123'), 'Length must be equal to 9'); 
        system.assertEquals(false, SirenService.checkSiren('12345678A'), 'Length must be equal to 9 and be numeric');
        system.assertEquals(true,  SirenService.checkSiren('732829320'));
        system.assertEquals(false, SirenService.checkSiren('732829310'));
        system.assertEquals(true, SirenService.checkSiren('420638041'));//
        system.assertEquals(true, SirenService.checkSiren('880759576'));
        system.assertEquals(true, SirenService.checkSiren('881376305'));
        system.assertEquals(true, SirenService.checkSiren('894582543'));
        system.assertEquals(true, SirenService.checkSiren('881376305'));
        system.assertEquals(true, SirenService.checkSiren('851730135'));
        system.assertEquals(true, SirenService.checkSiren('892506114'));
    } 
    
    @isTest
    private static void testCheckSiret() {
        system.assertEquals(false, SirenService.checkSiret('123456789'), 'Length must be equal to 14'); 
        system.assertEquals(false, SirenService.checkSiret('1234567891234R'), 'Length must be equal to 14 and be numeric');
        system.assertEquals(true, SirenService.checkSiret('73282932000074'));
        system.assertEquals(true, SirenService.checkSiret('42063804100020'));
        system.assertEquals(true, SirenService.checkSiret('52158845900011'));
        system.assertEquals(true, SirenService.checkSiret('50233094700016'));
        system.assertEquals(true, SirenService.checkSiret('83371088200014'));
        system.assertEquals(true, SirenService.checkSiret('42369986700036'));
    }
}