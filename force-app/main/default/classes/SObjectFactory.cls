/**
 *  @project SObjectBuilder
 *  @group SObjectBuilder
 *  @description This class can be used as a low level API to build or create SObjects of any given type. It provides
 *      the core functionality behind SObjectBuilder, and can be used in cases where SObjectBuilder is too complicated
 *      or overkill. Similarly to SObjectBuilder, this class can accept IFieldProviders in place of primitives when
 *      assigning fields.
 *  @example
 *      // Create a test account.
 *      Account testAccount = (Account)SObjectFactory.create(Account.sObjectType);
 *
 *      // Create a test opportunity and assign its parent to the test account.
 *      Opportunity testOpportunity = (Opportunity)SObjectFactory.create(Opportunity.sObjectType,
 *          Opportunity.AccountId, testAccount);
 *
 *      // Build 20 "Product" olis assigned to the test opportunity.
 *      List<OpportunityLineItem> testOppLineItems = SObjectFactory.build(20, OpportunityLineItem.sObjectType,
 *          'Product', OpportunityLineItem.OpportunityId, testOpportunity);
 */
@IsTest
public class SObjectFactory
{
    private static final String CREATE_ERROR = 'SObjectFactory Create failed. State: {0}, Cause: {1}';
    public class SObjectFactoryException extends Exception { }

    /**
     *  @description Gets a user from the organization which is a system administrator.
     */
    @testVisible
    public static User ADMIN_USER {
        get {
            if (ADMIN_USER == null) {
                ADMIN_USER = [
                    SELECT Id FROM User
                    WHERE Profile.PermissionsModifyAllData = true
                    AND IsActive = true
                    LIMIT 1
                ];
            }
            return ADMIN_USER;
        }
        private set;
    }

    public static SObject create(Schema.SObjectType objectType) { return create(1, objectType)[0]; }
    public static SObject build(Schema.SObjectType objectType) { return build(1, objectType)[0]; }

    public static SObject create(Schema.SObjectType objectType, String template) { return create(1, objectType, template)[0]; }
    public static SObject build(Schema.SObjectType objectType, String template) { return build(1, objectType, template)[0]; }

    public static List<SObject> create(Integer recordCount, Schema.SObjectType objectType) {
        return create(recordCount, objectType, (String)null /*template*/);
    }
    public static List<SObject> build(Integer recordCount, Schema.SObjectType objectType) {
        return build(recordCount, objectType, (String)null /*template*/);
    }

    public static List<SObject> create(Integer recordCount, Schema.SObjectType objectType, String template) {
        return create(new SObjectFactoryState(recordCount, objectType, template), null /*fieldToValue*/);
    }
    public static List<SObject> build(Integer recordCount, Schema.SObjectType objectType, String template) {
        return build(new SObjectFactoryState(recordCount, objectType, template), null /*fieldToValue*/);
    }

    public static SObject create(Schema.SObjectType objectType, Schema.SObjectField field, Object value) {
        return create(1, objectType, field, value)[0];
    }
    public static SObject build(Schema.SObjectType objectType, Schema.SObjectField field, Object value) {
        return build(1, objectType, field, value)[0];
    }

    public static SObject create(Schema.SObjectType objectType, String template, Schema.SObjectField field, Object value) {
        return create(1, objectType, template, field, value)[0];
    }
    public static SObject build(Schema.SObjectType objectType, String template,  Schema.SObjectField field, Object value) {
        return build(1, objectType, template, field, value)[0];
    }

    public static List<SObject> create(Integer recordCount, Schema.SObjectType objectType, Schema.SObjectField field, Object value) {
        return create(recordCount, objectType, (String)null /*template*/, field, value);
    }
    public static List<SObject> build(Integer recordCount, Schema.SObjectType objectType, Schema.SObjectField field, Object value) {
        return build(recordCount, objectType, (String)null /*template*/, field, value);
    }

    /**
     *  @description Builds and inserts one or more records of the given SObjectType, using the required fields cache.
     *  @param recordCount (Optional) The number of records to create. This will be 1 if not set.
     *  @param sObjectType The type of SObject to create.
     *  @param template (Optional) The template to use when creating these records.
     *  @param field (Optional) Assigns one field on the SObject to the passed in value.
     *  @param value (Optional) Assigns the field defined in "field" to this value. This could be a primitive, list,
     *      SObject, or IFieldProvider.
     *  @return If recordCount is set, a List<SObject> of records created. Otherwise, a single created SObject.
     */
    public static List<SObject> create(Integer recordCount, Schema.SObjectType objectType, String template, Schema.SObjectField field, Object value) {
        return create(new SObjectFactoryState(recordCount, objectType, template), new Map<Schema.SObjectField, Object> { field => value });
    }
    /**
     *  @description Builds but does not insert one or more records of the given SObjectType, using the required fields
     *      cache.
     *  @param recordCount (Optional) The number of records to create. This will be 1 if not set.
     *  @param sObjectType The type of SObject to create.
     *  @param template (Optional) The template to use when creating these records.
     *  @param field (Optional) Assigns one field on the SObject to the passed in value.
     *  @param value (Optional) Assigns the field defined in "field" to this value. This could be a primitive, list,
     *      SObject, or IFieldProvider.
     *  @return If recordCount is set, a List<SObject> of records built. Otherwise, a single built SObject.
     */
    public static List<SObject> build(Integer recordCount, Schema.SObjectType objectType, String template, Schema.SObjectField field, Object value) {
        return build(new SObjectFactoryState(recordCount, objectType, template), new Map<Schema.SObjectField, Object> { field => value });
    }

    /**
     *  @description Builds and inserts one or more records using the properties defined in the SObjectFactory state
     *      which is passed in. This method should not be called directly, and instead should only be used by the
     *      SObjectBuilder class.
     *  @param state The FactoryState to use when creating these records.
     *  @param fieldToValue The map of SObjectField to Object that defines which fields are assigned to which values.
     *      The values can be primitives, SObjects, Lists, or IFieldProviders.
     *  @return a List<SObject> of the records created.
     */
    public static List<SObject> create(SObjectFactoryState state, Map<Schema.SObjectField, Object> fieldToValue) {
        List<SObject> records = build(state, fieldToValue);
        try {
            insert records;
            return records;
        } catch (DmlException ex) {
            String msg = String.format(CREATE_ERROR, new List<String>{ state.toString(), ex.getMessage() });
            ex.setMessage(msg);
            throw ex;
        }
    }

    /**
     *  @description Builds but does not insert one or more records using the properties defined in the SObjectFactory
     *      state which is passed in. This method should not be called directly, and instead should only be used by the
     *      SObjectBuilder class.
     *  @param state The FactoryState to use when building these records.
     *  @param fieldToValue The map of SObjectField to Object that defines which fields are assigned to which values.
     *      The values can be primitives, SObjects, Lists, or IFieldProviders.
     *  @return a List<SObject> of the records built.
     */
    public static List<SObject> build(SObjectFactoryState state, Map<Schema.SObjectField, Object> fieldToValue) {
        Map<Schema.SObjectField, Object> fieldMap = RequiredFieldsCache.get(state.sObjectType, state.template);
        if (fieldToValue != null){
            fieldMap.putAll(fieldToValue);
        }
        initializeDynamicProviders(fieldMap, state);

        List<SObject> records = new List<SObject>();
        for (Integer i = 0; i < state.count; i++) {
            records.add(buildRecord(state.sObjectType, fieldMap));
        }
        return records;
    }

    /**
     *  @description Metabuilds a record with JSON methods, allowing typically read-only fields to be set. Similar to
     *      Build, these records use the properties defined in the SObjectFactory state which is passed in. This method
     *      should not be called directly, and instead should only be used by the SObjectBuilder class.
     *  @param state The FactoryState to use when building these records.
     *  @param fieldToValue The map of SObjectField to Object that defines which fields are assigned to which values.
     *      The values can be primitives, SObjects, Lists, or IFieldProviders.
     *  @return a List<SObject> of the records built.
     */
    public static List<SObject> metaBuild(SObjectFactoryState state, Map<Schema.SObjectField, Object> fieldToValue) {
        System.Type recordClass = System.Type.forName(String.valueOf(state.sObjectType));

        Map<Schema.SObjectField, Object> fieldMap = RequiredFieldsCache.get(state.sObjectType, state.template);
        if (fieldToValue != null) {
            fieldMap.putAll(fieldToValue);
        }
        initializeDynamicProviders(fieldMap, state);

        List<SObject> records = new List<SObject>();
        for (Integer i = 0; i < state.count; i++) {
            records.add(metaBuildRecord(recordClass, fieldMap));
        }
        return records;
    }

    @testVisible
    private static SObject buildRecord(Schema.SObjectType sObjectType, Map<Schema.SObjectField, Object> fieldMap) {
        Id recordId;
        SObject record = sObjectType.newSObject();

        for (Schema.SObjectField field : fieldMap.keySet()) {
            if (String.valueOf(field) == 'Id') {
                recordId = (Id)handleProviders(fieldMap.get(field));
            } else {
                record.put(field, handleProviders(fieldMap.get(field)));
            }
        }

        // Id is set last to prevent a -bug- feature where setting the Id on a record will make any non-reparentable
        // master detail relationships read-only.
        record.Id = recordId;
        return record;
    }

    @testVisible
    private static SObject metaBuildRecord(System.Type sObjectType, Map<Schema.SObjectField, Object> fieldMap) {
        Map<Schema.SObjectField, Object> metaFieldToValue = new Map<Schema.SObjectField, Object>();
        for (Schema.SObjectField field : fieldMap.keySet()){
            metaFieldToValue.put(field, handleProviders(fieldMap.get(field)));
        }
        return (SObject)JSON.deserialize(JSON.serialize(metaFieldToValue), sObjectType);
    }

    @testVisible
    private static void initializeDynamicProviders(Map<Schema.SObjectField, Object> fieldToValue, SObjectFactoryState state) {
        Object value;
        for (Schema.SObjectField field : fieldToValue.keySet()) {
            value = fieldToValue.get(field);
            if (value != null) {
                if (value instanceof IDynamicProvider) {
                    ((IDynamicProvider)value).initialize(state, field);
                } else if (value instanceof List<Object>) {
                    fieldToValue.put(field, new SObjectFieldProviders.ListProvider((List<Object>)value));
                }
            }
        }
    }

    @testVisible
    private static Object handleProviders(Object value) {
        if (value != null) {
            if (value instanceof IFieldProvider) {
                value = ((IFieldProvider)value).getValue();
            }
            if (value instanceof SObject) {
                value = ((SObject)value).Id;
            }
        }
        return value;
    }


    /** @deprecated */
    public static SObject create(Schema.SObjectType objectType, Map<Schema.SObjectField, Object> fieldToValue) {
        return create(1, objectType, fieldToValue)[0];
    }
    /** @deprecated */
    public static SObject build(Schema.SObjectType objectType, Map<Schema.SObjectField, Object> fieldToValue) {
        return build(1, objectType, fieldToValue)[0];
    }
    /** @deprecated */
    public static SObject create(Schema.SObjectType objectType, String template, Map<Schema.SObjectField, Object> fieldToValue) {
        return create(1, objectType, template, fieldToValue)[0];
    }
    /** @deprecated */
    public static SObject build(Schema.SObjectType objectType, String template, Map<Schema.SObjectField, Object> fieldToValue) {
        return build(1, objectType, template, fieldToValue)[0];
    }
    /** @deprecated */
    public static List<SObject> create(Integer recordCount, Schema.SObjectType objectType, Map<Schema.SObjectField, Object> fieldToValue) {
        return create(recordCount, objectType, null, fieldToValue);
    }
    /** @deprecated */
    public static List<SObject> build(Integer recordCount, Schema.SObjectType objectType, Map<Schema.SObjectField, Object> fieldToValue) {
        return build(recordCount, objectType, null, fieldToValue);
    }
    /** @deprecated */
    public static List<SObject> create(Integer recordCount, Schema.SObjectType objectType, String template, Map<Schema.SObjectField, Object> fieldToValue) {
        return create(new SobjectFactoryState(recordCount, objectType, template), fieldToValue);
    }
    /** @deprecated */
    public static List<SObject> build(Integer recordCount, Schema.SObjectType objectType, String template, Map<Schema.SObjectField, Object> fieldToValue) {
        return build(new SobjectFactoryState(recordCount, objectType, template), fieldToValue);
    }

    /** @deprecated */
    public static SObject metaBuild(Schema.SObjectType objectType) { return metaBuild(1, objectType)[0]; }
    /** @deprecated */
    public static SObject metaBuild(Schema.SObjectType objectType, String template) { return metaBuild(1, objectType, template)[0]; }
    /** @deprecated */
    public static List<SObject> metaBuild(Integer recordCount, Schema.SObjectType objectType) {
        return metaBuild(recordCount, objectType, null, new Map<Schema.SObjectField, Object>());
    }
    /** @deprecated */
    public static List<SObject> metaBuild(Integer recordCount, Schema.SObjectType objectType, String template) {
        return metaBuild(recordCount, objectType, template, new Map<Schema.SObjectField, Object>());
    }
    /** @deprecated */
    public static SObject metaBuild(Schema.SObjectType objectType, Schema.SObjectField field, Object value) {
        return metaBuild(objectType, new Map<Schema.SObjectField, Object> { field => value });
    }
    /** @deprecated */
    public static List<SObject> metaBuild(Integer recordCount, Schema.SObjectType objectType, Schema.SObjectField field, Object value) {
        return metaBuild(recordCount, objectType, new Map<Schema.SObjectField, Object> { field => value });
    }
    /** @deprecated */
    public static SObject metaBuild(Schema.SObjectType objectType, String template,  Schema.SObjectField field, Object value) {
        return metaBuild(objectType, template, new Map<Schema.SObjectField, Object> { field => value });
    }
    /** @deprecated */
    public static SObject metaBuild(Schema.SObjectType objectType, Map<Schema.SObjectField, Object> fieldToValue) {
        return metaBuild(1, objectType, fieldToValue)[0];
    }
    /** @deprecated */
    public static SObject metaBuild(Schema.SObjectType objectType, String template, Map<Schema.SObjectField, Object> fieldToValue) {
        return metaBuild(1, objectType, template, fieldToValue)[0];
    }
    /** @deprecated */
    public static List<SObject> metaBuild(Integer recordCount, Schema.SObjectType objectType, String template, Schema.SObjectField field, Object value) {
        return metaBuild(recordCount, objectType, template, new Map<Schema.SObjectField, Object> { field => value });
    }
    /** @deprecated */
    public static List<SObject> metaBuild(Integer recordCount, Schema.SObjectType objectType, Map<Schema.SObjectField, Object> fieldToValue) {
        return metaBuild(recordCount, objectType, null, fieldToValue);
    }
    /** @deprecated */
    public static List<SObject> metaBuild(Integer recordCount, Schema.SObjectType objectType, String template, Map<Schema.SObjectField, Object> fieldToValue) {
        return metaBuild(new SobjectFactoryState(recordCount, objectType, template), fieldToValue);
    }

    // <Legacy Methods> (If Installed)
    // End Legacy Methods
}