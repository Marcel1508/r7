@isTest
public with sharing class MockFieldProvider implements IDynamicProvider {
    public Integer initializeCalls { get; private set; }
    public Integer getValueCalls { get; private set; }
    public SObjectFactoryState initializedState { get; private set; }
    public SObjectField initializedField { get; private set; }

    public final Object returnValue;

    public MockFieldProvider() {
        initializeCalls = 0;
        getValueCalls = 0;
    }

    public MockFieldProvider(Object returnValue) {
        this();
        this.returnValue = returnValue;
    }

    public void initialize(SObjectFactoryState state, SObjectField field) {
        initializeCalls++;
        initializedState = state;
        initializedField = field;
    }

    public Object getValue() {
        getValueCalls++;
        return returnValue;
    }
}