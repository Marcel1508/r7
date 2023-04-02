/**
 *  @project SObjectBuilder
 *  @group SObjectBuilder
 *  @description This is a wrapper class which contains commonly used field providers.
 */
@IsTest
public class SObjectFieldProviders {
    private static final String ERROR_INVALID_PADDING = 'The character "{0}" is not a valid padding character. It must have a length of 1.';
    private static final String ERROR_NON_ID_FIELD = 'Dynamic ID providers can only be used on ID fields and Lookup fields. "{0}.{1}" is not a lookup or Id.';
    private static final String ERROR_MISSING_PROFILE = 'The profile "{0}" does not exist.';

    private static Integer uniqueCounter = 0;
    /**
     *  @description Gets a unique number for the current context.
     *  @return A unique number.
     */
    public static Integer getUniqueCounter() { return uniqueCounter++; }

    public virtual class FieldProviderException extends Exception { }

    // Used by ProfileProvider
    private static Map<String, Profile> profilesByName {
        get {
            if (profilesByName == null) {
                profilesByName = new Map<String, Profile>();
                for (Profile profile : [SELECT Name FROM Profile]) {
                    profilesByName.put(profile.Name, profile);
                }
            }
            return profilesByName;
        }
        private set;
    }

    /**
     *  @description Gets a field provider which will provide the Standard User profile Id.
     */
    public static IFieldProvider standardProfileProvider {
        get {
            if (standardProfileProvider == null) {
                standardProfileProvider = new ProfileProvider('Standard User');
            }
            return standardProfileProvider;
        }
        private set;
    }

    /**
     *  @description Gets a field provider which will provide the System Administrator profile Id.
     */
    public static IFieldProvider adminProfileProvider {
        get {
            if (adminProfileProvider == null) {
                adminProfileProvider = new ProfileProvider('System Administrator');
            }
            return adminProfileProvider;
        }
        private set;
    }

    /**
     *  @description A provider which generates a unique string for each record, with an optional prefix.
     *  @example
     *      // Generate Opportunities with a unique name, starting with "Opportunity-"
     *      List<Opportunity> myOpportunities = new SObjectBuilder(Opportunity.sObjectType)
     *          .put(Opportunity.Name, new SObjectFieldProviders.UniqueStringProvider('Opportunity-'))
     *          .count(22).create().getRecords();
     */
    public virtual class UniqueStringProvider implements IFieldProvider {
        public String base { get; protected set; }

        /**
         *  @description Creates a new instance of a UniqueStringProvider, with no prefix.
         */
        public UniqueStringProvider() {
            this.base = '';
        }

        /**
         *  @description Creates a new instance of a UniqueStringProvider, with a prefix.
         *  @param base The prefix that each unique string will start with.
         */
        public UniqueStringProvider(String base) {
            this.base = base;
        }

        public virtual Object getValue() {
            return this.base + String.valueOf(getUniqueCounter());
        }
    }

    /**
     *  @description A provider which generates a unique string for each record, guaranteeing that each generated string
     *      will be exactly the length provided. Optionally, a prefix can be included as well.
     *  @example
     *      // Create a series of Products, each with a unique 12 digit serial number.
     *      List<Product2> myProducts = new SObjectBuilder(Product2.sObjectType)
     *          .put(Product2.SerialNumber__c, new UniqueFixedLengthStringProvider(12))
     *          .count(70).create().getRecords();
     */
    public virtual class UniqueFixedLengthStringProvider
        extends UniqueStringProvider
        implements IFieldProvider
    {
        /**
         *  @description Gets the length of the string that will be generated.
         */
        public Integer length { get; protected set; }
        /**
         *  @description Gets the padding character that will be used to pad the fixed length string.
         */
        public String character { get; protected set; }

        /**
         *  @description Creates a new instance of a UniqueFixedLengthStringProvider, with strings of the given length,
         *      no prefix, and a default padding of "0".
         *  @param length The length of the unique strings that will be generated.
         */
        public UniqueFixedLengthStringProvider(Integer length) {
            this('', length);
        }

        /**
         *  @description Creates a new instance of a UniqueFixedLengthStringProvider, with strings of the given length,
         *      starting with the given base, and padded with the default padding of "0".
         *  @param base The prefix for each unique string generated.
         *  @param length The length of the unique strings that will be generated.
         */
        public UniqueFixedLengthStringProvider(String base, Integer length) {
            this(base, length, '0');
        }

        /**
         *  @description Creates a new instance of a UniqueFixedLengthStringProvider, with strings of the given length,
         *      no prefix, and a given padding.
         *  @param length The length of the unique strings that will be generated.
         *  @param character The padding character used to pad the fixed length string.
         */
        public UniqueFixedLengthStringProvider(Integer length, String character) {
            this('', length, character);
        }


        /**
         *  @description Creates a new instance of a UniqueFixedLengthStringProvider, with strings of the given length,
         *      starting with the given base, and a given padding.
         *  @param base The prefix for each unique string generated.
         *  @param length The length of the unique strings that will be generated.
         *  @param character The padding character used to pad the fixed length string.
         */
        public UniqueFixedLengthStringProvider(String base, Integer length, String character) {
            super(base);
            if (character.length() != 1) {
                throw new FieldProviderException(String.format(
                    ERROR_INVALID_PADDING, new List<String>{ character }
                ));
            }
            this.character = character;
            this.length = length;
        }

        public override virtual Object getValue() {
            String uniqueSuffix = String.valueOf(getUniqueCounter());
            Integer padding = this.length - this.base.length();

            if (padding >= uniqueSuffix.length()) {
                return this.base + uniqueSuffix.leftPad(padding).replace(' ', this.character);
            } else {
                Integer overlap = this.length - uniqueSuffix.length();
                return this.base.substring(0, overlap) + uniqueSuffix;
            }
        }
    }

    /**
     *  @description A provider which will generate a unique, fake Id for each record generated using this provider.
     *  @example
     *      // Build a hundred cases, each with a fake Id, and a fake Account lookup.
     *      List<Case> testCases = new SObjectBuilder(Case.sObjectType)
     *          .put(Case.Id, new SObjectFieldProviders.DummyIdProvider(Case.sObjectType))
     *          .put(Case.AccountId, new SobjectFieldProviders.DummyIdProvider())
     *          .create(100).build().getRecords();
     */
    public class DummyIdProvider
        extends UniqueFixedLengthStringProvider
        implements IDynamicProvider
    {
        /**
         *  @description Creates a new instance of a DummyIdProvider, which will intelligently decide which types of
         *      Ids to generate based on the field it is being assigned to. This works with Lookups, Master Details, and
         *      Id fields. If a polymorphic field is assigned to (WhatId on a Task), then a parent will be chosen
         *      pseudo-randomly.
         */
        public DummyIdProvider() {
            super('', 15, '0');
        }

        /**
         *  @description Creates a new instance of a DummyIdProvider, which will generate dummy Ids for objects of the
         *      passed in SObjectType.
         *  @param sObjectType The sObjectType of the Ids to generate.
         */
        public DummyIdProvider(Schema.SObjectType sObjectType) {
            this(sObjectType.getDescribe().getKeyPrefix(), 15);
        }

        /**
         *  @description Creates a new instance of a DummyIdProvider, which will generate dummy Ids for objects of the
         *      passed in SObjectType. This also allows the Id length to be specified.
         *  @param sObjectType The sObjectType of the Ids to generate.
         *  @param length The length (15 or 18) of the Id to generate.
         */
        public DummyIdProvider(Schema.SObjectType sObjectType, Integer length) {
            this(sObjectType.getDescribe().getKeyPrefix(), length);
        }

        /**
         *  @description Creates a new instance of a DummyIdProvider, which will generate dummy Ids using the prefix
         *      passed in.
         *  @param prefix The prefix of the Ids to generate.
         */
        public DummyIdProvider(String prefix) {
            this(prefix, 15);
        }

        /**
         *  @description Creates a new instance of a DummyIdProvider, which will generate dummy Ids using the prefix
         *      passed in. This also allows the Id length to be specified.
         *  @param prefix The prefix of the Ids to generate.
         *  @param length The length (15 or 18) of the Id to generate.
         */
        public DummyIdProvider(String prefix, Integer length) {
            super(prefix, length, '0');
        }

        public virtual void initialize(SObjectFactoryState state, Schema.SObjectField field) {
            if (String.isBlank(this.base)) {
                Schema.DescribeFieldResult describe = field.getDescribe();

                if (describe.getName() == 'Id') {
                    this.base = state.sObjectType.getDescribe().getKeyPrefix();
                } else {
                    List<Schema.SObjectType> lookupTypes = describe.getReferenceTo();
                    if (lookupTypes.isEmpty()) {
                        throw new FieldProviderException(String.format(ERROR_NON_ID_FIELD, new List<String>{
                            String.valueOf(state.sObjectType), String.valueOf(field)
                        }));
                    }
                    this.base = lookupTypes[0].getDescribe().getKeyPrefix();
                }
            }
        }
    }

    /**
     *  @description A provider which will assign values from the list in order. If the number of records being
     *      generated is longer than the list size, then after each value has been assigned, the provider will restart
     *      from the beginning of the list.
     *  @example
     *      // Create 20 opportunities, with alternating stage names.
     *      List<String> stages = new List<String>{ 'Closed/Won', 'Closed/Lost' };
     *      List<Opportunity> myOpportunities = new SObjectBuilder(Opportunity.sObjectType)
     *          .put(Opportunity.StageName, new SObjectFieldProviders.ListProvider(stages))
     *          .count(20).create().getRecords();
     */
    public virtual class ListProvider implements IFieldProvider {
        public Integer index { get; protected set; }
        public List<Object> values { get; protected set; }

        /**
         *  @description Creates a new instance of a list provider, but without a pre-set list. The overloading class
         *      must implement logic to populate the values.
         */
        protected ListProvider() {
            this.index = 0;
        }

        /**
         *  @description Creates a new instance of a list provider, providing values from the passed in list.
         *  @param values The values to provide to each record.
         */
        public ListProvider(List<Object> values) {
            this.index = 0;
            this.values = values;
        }

        /** @deprecated Sets do not automatically cast. */
        public ListProvider(Set<Object> values) {
            this(new List<Object>(values));
        }

        public Object getValue() {
            Object value = this.values[index];
            this.index = math.mod(this.index + 1, this.values.size());
            return value;
        }
    }

    /**
     *  @description A provider which will assign values from another provider, repeating each value a certain number of
     *               times. This provider will work with lists and any other provider.
     *  @example
     *      // Create 4 opportunities, with each combination of closed/won - closed/lost and enterprise - individual.
     *      List<String> stages = new List<String>{ 'Closed/Won', 'Closed/Lost' };
     *      List<Opportunity> myOpportunities = new SObjectBuilder(Opportunity.sObjectType)
     *          .put(Opportunity.Type, new List<String>{ 'Enterprise', 'Individual' })
     *          .put(Opportunity.StageName, new SObjectFieldProviders.RepeatingProvider(stages, 2))
     *          .count(4).create().getRecords();
     */
    public class RepeatingProvider implements IDynamicProvider {
        public IFieldProvider childProvider { get; protected set; }
        public Integer repeats { get; protected set; }

        private Integer calls = 0;
        private Object currentValue;

        /**
         *  @description Creates a new instance of a repeating provider, which repeats the values provided by the
         *               given provider, repeats number of times.
         *  @param childProvider The provider which provides the actual values.
         *  @param repeats The number of times to repeat each value from the child provider.
         */
        public RepeatingProvider(IFieldProvider childProvider, Integer repeats) {
            this.childProvider = childProvider;
            this.repeats = repeats;
        }

        /**
         *  @description Creates a new instance of a repeating provider, which will repeat each value from a list
         *               the given number of times.
         *  @param values A list of values to iterate over.
         *  @param repeats the number of time to repeat each value in the list.
         */
        public RepeatingProvider(List<Object> values, Integer repeats) {
            this(new ListProvider(values), repeats);
        }

        public void initialize(SObjectFactoryState state, Schema.SObjectField targetField) {
            if (childProvider instanceof IDynamicProvider) {
                ((IDynamicProvider)childProvider).initialize(state, targetField);
            }
        }

        public Object getValue() {
            if (calls == 0) {
                currentValue = childProvider.getValue();
            }
            calls++;
            if (calls == repeats) {
                calls = 0;
            }
            return currentValue;
        }
    }

    /**
     *  @description A provider which provides ProfileIds for user records, based on the Profile's Name.
     *  @example
     *      // Create three standard users.
     *      List<User> testUsers = new SObjectBuilder(User.sObjectType)
     *          .put(User.ProfileId, new SObjectFieldProviders.ProfileProvider('Standard User'))
     *          .count(3).create().getRecords();
     */
    public class ProfileProvider implements IFieldProvider {
        private String profileName;
        private Id profileId {
            get {
                if (profileId == null) {
                    Profile profile = profilesByName.get(profileName);
                    if (profile == null) {
                        throw new SObjectFieldProviders.FieldProviderException(String.format(
                            ERROR_MISSING_PROFILE, new List<String>{ profileName }
                        ));
                    }
                    profileId = profile.Id;
                }
                return profileId;
            }
            set;
        }

        /**
         *  @description Creates a new instance of a profile provider, which will provide the Id for the profile with
         *      the given name.
         *  @param profileName The name of the profile to get.
         */
        public ProfileProvider(String profileName) {
            this.profileName = profileName;
        }

        public Object getValue() {
            return this.profileId;
        }
    }

    /**
     *  @description A provider which will retrieve the record type Id for the given developer name.
     *  @example
     *      // Create three accounts with the "Small Business" record type.
     *      List<Account> testUsers = new SObjectBuilder(User.sObjectType)
     *          .put(User.RecordTypeId, new SObjectFieldProviders.RecordTypeProvider('Small_Business'))
     *          .count(3).create().getRecords();
     */
    public class RecordTypeProvider implements IDynamicProvider {
        public final String recordTypeName;
        public Id recordTypeId { get; protected set; }

        /**
         *  @description Creates a new instance of a record type provider, which will automatically determine the object
         *      type to use.
         *  @param developerName The developer name of the record type to use.
         */
        public RecordTypeProvider(String developerName) {
            recordtypename = developerName;
        }
        /**
         *  @description Creates a new instance of a record type provider, which will provide a record type Id for the
         *      given object type.
         *  @param developerName The developer name of the record type to use.
         *  @param objectType The object type for this record type.
         */
        public RecordTypeProvider(String developerName, Schema.SObjectType objectType) {
            recordTypeName = developerName;
            recordTypeId = objectType.getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        }

        public void initialize(SObjectFactoryState state, Schema.SObjectField targetField) {
            if (recordTypeId == null) {
                recordTypeId = state.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
            }
        }

        public Object getValue() {
            return recordTypeId;
        }
    }

    /**
     *  @description Similar to a list provider, except this provider will iterate over each record in the provided list
     *      and copy the given field off that record.
     *  @example
     *      // Create four accounts with different names.
     *      List<Account> testAccounts = new SObjectBuilder(Account.sObjectType)
     *          .put(Account.Name, new SObjectFieldProviders.UniqueStringProvider())
     *          .count(4).create().getRecords();
     *
     *      // Creates four opportunities which have the same name as the previous accounts
     *      List<Opportunity> testOpportunitys = new SObjectBuilder(Opportunity.sObjectType)
     *          .put(Opportunity.Name, new SObjectFieldProviders.PluckProviders(Account.Name, testAccounts))
     *          .count(4).create().getRecords();
     */
    public class PluckProvider implements IFieldProvider {
        public final SObjectField field;
        public final List<SObject> records;
        public Integer index { get; protected set; }

        /**
            @description creates a new instance of a pluck provider..
            @param field The field to pull off each record
            @param records The list of records to copy from.
        */
        public PluckProvider(SObjectField field, List<SObject> records) {
            this.field = field;
            this.records = records;
            index = 0;
        }

        public Object getValue() {
            SObject record = this.records[index];
            this.index = math.mod(this.index + 1, this.records.size());
            return record.get(field);
        }
    }

    // <Legacy Methods> (If Installed)
    // End Legacy Methods
}