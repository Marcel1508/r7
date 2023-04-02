/**
 *  @project SObjectBuilder
 *  @group SObjectBuilder
 *  @description This interface defines a type that can be used to generate many different values for a field on a
 *      series of SObjects. In addition to supporting the same functionality as IFieldProvider, IDynamicProvider also
 *      provides a method which is called once each build(), create() or metabuild(), that provides the provider with
 *      information about how the SObjectBuilder is being used. This allows the provider to adjust what it generates
 *      based on, for example, the number of records being generated, or the field it is being assigned to.
 *
 *      For examples, take a look at the various providers which implement IDynamicProvider in the SObjectFieldProviders
 *      class.
 */
public interface IDynamicProvider extends IFieldProvider {
    /**
     *  @description When implemented, this method will be called once per build(), create(), or metabuild(), passing
     *      in the factory state and field this provider is being used for.
     *  @param factoryState The parameters that have been passed to the SObjectFactory.
     *  @param field the SObjectField this provider is providing for.
     */
    void initialize(SObjectFactoryState factoryState, Schema.SObjectField field);
}