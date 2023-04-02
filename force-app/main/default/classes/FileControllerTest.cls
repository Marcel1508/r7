@isTest
public class FileControllerTest {
    @testSetup
    private static void init() {
       Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('Test Magasin');
        Insert magasinRec;
        
        Account accTest = TestDataFactory.createGenericAccountRecord('TestAcc','Lead',magasinRec); 
        Insert accTest;
    } 
    
    @isTest
    private static void testGetAccountFilesOptions() {
        Account a = [SELECT ID FROM ACCOUNT LIMIT 1];
        FileController.getAccountFilesOptions(a.Id);
    }
    
    @isTest
    private static void testUpdateAccount() {
        Account a = [SELECT ID FROM ACCOUNT LIMIT 1];
        FileController.updateAccount(a.Id, 'RIB');
        FileController.updateAccount(a.Id, 'kbis');
        FileController.updateAccount(a.Id, 'Piece_identite');
        FileController.updateAccount(a.Id, 'Registre du commerce');
    }
    
    @isTest
    private static void testdeleteFile() {
        Account a = [SELECT ID FROM ACCOUNT LIMIT 1];
        FileController.deleteFile(null, a.Id, 'RIB');
        FileController.deleteFile(null, a.Id, 'kbis');
        FileController.deleteFile(null, a.Id, 'Piece_identite');
        FileController.deleteFile(null, a.Id, 'Registre du commerce');
    }
    
    @isTest
    private static void testgetFilesList() {
        Account a = [SELECT ID FROM ACCOUNT LIMIT 1];
        FileController.getFilesList(a.id);
        FileController.FilesWrapper fc = new FileController.FilesWrapper(null, 'Capture', 'Marouane', Date.Today(), '1.2', 'RIB', 1);
    }
}