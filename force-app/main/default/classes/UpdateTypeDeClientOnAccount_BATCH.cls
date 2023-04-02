/**
 * @CreatedBy       : Suliman A.
 * @Date            : 18/08/2021
 * @Company         : IBM, Bluewolf
 * @Description     : A Batch to update Type_de_client__c field on Account by calculate the value of Montant_total_HT__c field on Facture__c object.
 */
public without sharing class UpdateTypeDeClientOnAccount_BATCH implements Database.Batchable<sObject>, Database.Stateful {
    /**
     * start()
     * Query all the Account from database to be processed in execute method
     * @param bc    Parameter type of a batch job method and contains the batch job ID
     * @return      Records set to process
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT ID, Type_de_client__c FROM Account';
        return Database.getQueryLocator(query);
    }

    /**
     * execute()
     * Calculate Montant_total_HT__c value to set Type_de_client__c 's value on Account
     * @param bc    Parameter type of a batch job method and contains the batch job ID
     * @param scope Record to process
     */
    public void execute(Database.BatchableContext bc, List<Account> scope) {
        //Sort Accounts by their Id
        Map<Id, Account> accountsByIdMap = new Map<Id, Account>();
        for (Account a : scope) {
            accountsByIdMap.put(a.Id, a);
        }

        //Retrieve batch parameters
        UpdateTypeDeClientOnAccount__mdt batchParameters = [
            SELECT Label, Type_A_Limit__c, Type_B_Limit_1__c, Type_B_Limit_2__c, Type_C_Limit__c
            FROM UpdateTypeDeClientOnAccount__mdt
            LIMIT 1
        ];
        Integer Type_A_Limit = batchParameters.Type_A_Limit__c.intValue();
        Integer Type_B_Limit_1 = batchParameters.Type_B_Limit_1__c.intValue();
        Integer Type_B_Limit_2 = batchParameters.Type_B_Limit_2__c.intValue();
        Integer Type_C_Limit = batchParameters.Type_C_Limit__c.intValue();

        //Update Type_de_client__c field on Account
        List<Account> accountsToUpdate = new List<Account>();
        for (AggregateResult totalAmountByAccount : [
            SELECT Code_carte_client__c, SUM(Montant_total_HT__c) TotalAmount
            FROM Facture__c
            WHERE Code_carte_client__c IN :scope AND Date_de_facture__c >= LAST_N_DAYS:365 AND Date_de_facture__c != NULL
            GROUP BY Code_carte_client__c
        ]) {
            //Retrieve totalAmount by account id
            Decimal totalAmount = (Decimal) totalAmountByAccount.get('TotalAmount');
            Id accountId = (Id) totalAmountByAccount.get('Code_carte_client__c');

            Account acc = new Account();
            //If the sum of Montant_total_HT__c is LESS THAN 8000, set Type_de_client__c on Account to 'CLIENT C'
            if (totalAmount <= Type_C_Limit) {
                if (accountsByIdMap.get(accountId).Type_de_client__c != Constants.TypeClientC) {
                    acc.Id = accountId;
                    acc.Type_de_client__c = Constants.TypeClientC;
                    accountsToUpdate.add(acc);
                }
            } //If the sum of Montant_total_HT__c is BETWEEN 8000 & 30000, set Type_de_client__c on Account to 'CLIENT B'
            else if (totalAmount > Type_B_Limit_1 && totalAmount <= Type_B_Limit_2) {
                if (accountsByIdMap.get(accountId).Type_de_client__c != Constants.TypeClientB) {
                    acc.Id = accountId;
                    acc.Type_de_client__c = Constants.TypeClientB;
                    accountsToUpdate.add(acc);
                }
            } //If the sum of Montant_total_HT__c is MORE THAN 30000, set Type_de_client__c on Account to 'CLIENT A'
            else if (totalAmount > Type_A_Limit) {
                if (accountsByIdMap.get(accountId).Type_de_client__c != Constants.TypeClientA) {
                    acc.Id = accountId;
                    acc.Type_de_client__c = Constants.TypeClientA;
                    accountsToUpdate.add(acc);
                }
            }
        }
        List<Database.SaveResult> saveResults = Database.update(accountsToUpdate, false);

        // create errors logs
        createErrorsLogs(bc, accountsToUpdate, saveResults);
    }

    /**
     * finish()
     * Method is called after all batches are processed.
     * @param bc    Parameter type of a batch job method and contains the batch job ID
     */
    public void finish(Database.BatchableContext bc) {
        // do nothing
    }

    /**
     * createErrorsLogs()
     * Create errors logs for each rejected records of the batch
     * @param bc                Parameter type of a batch job method and contains the batch job ID
     * @param accountsToUpdate  Accounts updated
     * @param saveResultsList   The result of an insert or update DML operation returned by a Database method.
     */
    private void createErrorsLogs(
        Database.BatchableContext bc,
        List<Account> accountsToUpdate,
        List<Database.SaveResult> saveResultsList
    ) {
        // get job info
        AsyncApexJob job = [
            SELECT Id, CreatedDate
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()
        ];

        List<Error_Log__c> errorsLogsList = new List<Error_Log__c>();
        for (Integer i = 0; i < accountsToUpdate.size(); i++) {
            // get record details and its save details
            Account account = accountsToUpdate.get(i);
            Database.SaveResult saveRes = saveResultsList.get(i);

            List<Error_Log__c> errLog = generateErrorLogs(job, account, saveRes);
            if (errLog != null) {
                errorsLogsList.addAll(errLog);
            }
        }

        insert errorsLogsList;
    }

    /**
     * generateErrorLog()
     * Generate errors log coming from a rejected account
     * @param job       job details such as id and create date
     * @param account   Account updated
     * @param saveRes   The result of an insert or update DML operation returned by a Database method
     * @return          the list of errors found for a record
     */
    private List<Error_Log__c> generateErrorLogs(AsyncApexJob job, Account account, Database.SaveResult saveRes) {
        // initalise error logs list
        List<Error_Log__c> errorsLogsList = new List<Error_Log__c>();

        // generate apex errors log record if errors were found
        if (!saveRes.isSuccess()) {
            // generate an error log for each errors found
            for (Database.Error err : saveRes.getErrors()) {
                Error_Log__c errorLog = new Error_Log__c(
                    Name = 'UpdateTypeDeClientOnAccount ' + job.Id,
                    Batch_Name__c = 'MAJ_TypeDeClientOnAccountBATCH',
                    ID_Job__c = job.Id,
                    Job_Name__c = 'UpdateTypeDeClientOnAccount',
                    Execution_Time__c = job.CreatedDate,
                    Error__c = generateErrorMsg(account, err)
                );
    
                // add error log to errors logs list
                errorsLogsList.add(errorLog);
            }
        }

        // no error found
        return errorsLogsList;
    }

    /**
     * generateErrorMsg()
     * Generate an error message from all errors encountered on one record
     * @param account   Account updated
     * @param err       Error raised from record in parameter
     * @return          custom error message formatted as: <status_code> on <account_id> -- <error_message>
     */
    private String generateErrorMsg(Account account, Database.Error err) {
        return  err.getStatusCode() + ' on ' + account.Id + ' -- ' + err.getMessage();
    }
}