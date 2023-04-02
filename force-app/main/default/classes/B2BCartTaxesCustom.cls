/**
* @author       jan.straka@bluewolf, aymen.mtir@ibm
* @date         2021-01-29
* @description  Service for B2B Checkout cart taxes calculation
**/
public without sharing class B2BCartTaxesCustom {
    
    @TestVisible
    private static final Date TODAY_DATE = Date.today();
    
    @InvocableMethod(label='Calculate Taxes - custom' description='Calculate Taxes per each Cart Item' category='Promocash')
    public static void calculateTaxes(List<String> cartIds) {
        List<CartItem> cartItems = getCartItems((Id) cartIds[0]);
        List<CartItem> cartItemsToUpdate = new List<CartItem>();
        
        Frais__c frais = getFrais(cartItems[0].Cart.Account.Frais_autorisations__c);
        
        Map<String, Taxes__c> taxes = getTaxesByCodeTVA(
            frais.Zone_territoriale__c, 
            Pluck.strings('Product2.Code_TVA__c', cartItems));
        
        Map<String, Taxe_Emballage__c> taxesConsigne = getTaxesConsigneByCodeEmballage(Pluck.strings('Product2.Code_emballage__c', cartItems));
        Map<Id, CartTax> cartTaxes = getCartTaxesByCartItemId(Pluck.ids(cartItems));
        
        delete cartTaxes.values();
        cartTaxes = null;
       
        Map<Id, CartTax> cartTVA2 = new Map<Id, CartTax>();
        Map<Id, CartTax> cartEcotaxe2 = new Map<Id, CartTax>();
        Map<Id, CartTax> cartTaxeEmballage2 = new Map<Id, CartTax>();
        Map<Id,List<cartTax>> cartTaxesByCartItem = getCartTaxesByCartItemIdAndType(Pluck.ids(cartItems),new List<String>{'TVA','Ecotaxe','Consigne'});
        List<cartTax> cartTaxesList = new List<cartTax>();
        if(!cartTaxesByCartItem.isEmpty()){
            
            for(Id itemId : cartTaxesByCartItem.keySet())
            {
                cartTaxesList = cartTaxesByCartItem.get(itemId);
                if(cartTaxesList != null && !cartTaxesList.isEmpty())
                {
                    for(CartTax ct: cartTaxesList)
                    {
                        if(ct.Name == 'TVA'){
                            cartTVA2.put(itemId,ct);     
                        } else if(ct.Name == 'Ecotaxe'){
                            cartEcotaxe2.put(itemId,ct);
                        }else if(ct.Name == 'Consigne')
                        {
                            cartTaxeEmballage2.put(itemId,ct);
                        }     
                    }
                }  
            } 
        }
        
        
        List<CartTax> cartTaxesToUpsert = new List<CartTax>();
        
        
        for (CartItem cartItem : cartItems) {
            //  CartTax cartItemTVA = cartTaxes.get(cartItem.Id);     
            CartTax cartItemTVA = cartTVA2.get(cartItem.Id);            
            CartTax cartItemEcotaxe = cartEcotaxe2.get(cartItem.Id);            
            CartTax cartItemTaxeEmballage = cartTaxeEmballage2.get(cartItem.Id);
            
            if (cartItemTVA == null) {
                cartItemTVA = new CartTax(
                    // CartId = cartId,
                    CartItemId = cartItem.Id,
                    Name =  'TVA',
                    TaxType = 'Actual'
                );
            }
            Taxes__c tax = taxes.get(cartItem.Product2.Code_TVA__c);
            if (tax == null) {
                //throw new B2BCheckoutTaxesException('No Taxes__c record found for (Product Id:' + cartItem.Product2Id + ', Frais Id:' + frais.Id + ')');
                cartItemTVA.TaxRate = 0;
                cartItemTVA.Amount = 0;
            }else{
                cartItemTVA.TaxRate = tax.Taux_de_TVA__c;
                if(tax.Taux_de_TVA__c != null && cartItem.TotalPrice != null)
                    cartItemTVA.Amount = cartItem.TotalPrice * tax.Taux_de_TVA__c / 100;
                else
                    cartItemTVA.Amount =0;
            }
            cartItemTVA.TaxCalculationDate = TODAY_DATE;
            
            
            if (cartItemEcotaxe == null) {
                cartItemEcotaxe = new CartTax(
                    // CartId = cartId,
                    CartItemId = cartItem.Id,
                    Name =  'Ecotaxe',
                    TaxType = 'Actual'
                );
            }  
            if (cartItem.Product2.Ecotaxe__c == null) {
                //throw new B2BCheckoutTaxesException('No Taxes__c record found for (Product Id:' + cartItem.Product2Id + ', Frais Id:' + frais.Id + ')');
                cartItemEcotaxe.TaxRate = 0;
                cartItemEcotaxe.Amount = 0;
                cartItemEcotaxe.MontantEcotaxe__c = 0;
            }else{
               // cartItemEcotaxe.Amount = cartItem.Product2.Ecotaxe__c;
                cartItemEcotaxe.Amount = 0;
                cartItemEcotaxe.MontantEcotaxe__c = cartItem.Product2.Ecotaxe__c * cartItem.Quantity;
            }
            
            // cartItemEcotaxe.Amount = 1;
            //   cartItemEcotaxe.Amount = cartItem.Product2.Ecotaxe__c;
            cartItemEcotaxe.TaxCalculationDate = TODAY_DATE;
            
            
            if (cartItemTaxeEmballage == null) {
                cartItemTaxeEmballage = new CartTax(
                    // CartId = cartId,
                    CartItemId = cartItem.Id,
                    Name =  'Consigne',
                    TaxType = 'Actual'
                );
            }
            cartItemTaxeEmballage.Amount = 0;
            Taxe_Emballage__c taxeConsigne = taxesConsigne.get(cartItem.Product2.Code_emballage__c);
            if (taxeConsigne == null) {
                cartItemTaxeEmballage.TaxRate = 0;
                cartItemTaxeEmballage.Amount = 0;
            }else if(taxesConsigne.get(cartItem.Product2.Code_emballage__c).Prix_consigne_emballage__c == 0 ||
                     taxesConsigne.get(cartItem.Product2.Code_emballage__c).Prix_consigne_emballage__c == null){
                         cartItemTaxeEmballage.TaxRate = 0;
                         cartItemTaxeEmballage.Amount = 0;
                     }else{
                         cartItemTaxeEmballage.TaxRate = 0;
                         cartItemTaxeEmballage.Amount = taxesConsigne.get(cartItem.Product2.Code_emballage__c).Prix_consigne_emballage__c*cartItem.Quantity;
                     }
            
            //cartItemTaxeEmballage.Amount = taxesConsigne.get(cartItem.Product2.Code_emballage__c).Prix_consigne_emballage__c;
            //  cartItemTaxeEmballage.Amount = cartItem.Product2.Ecotaxe__c;taxesConsigne
            cartItemTaxeEmballage.TaxCalculationDate = TODAY_DATE;
            
            cartTaxesToUpsert.add(cartItemTVA);
            cartTaxesToUpsert.add(cartItemEcotaxe);
            cartTaxesToUpsert.add(cartItemTaxeEmballage);
        }
        
        upsert cartTaxesToUpsert;
        //       update cartItemsToUpdate;
        
        //  getCartTaxesByCartItemId(Pluck.ids(cartItems))
        
    }
    
    private static List<CartItem> getCartItems(Id cartId) {
        List<CartItem> cartItems = [
            SELECT Id, Product2Id, Product2.Code_TVA__c, Product2.Ecotaxe__c, Product2.Code_emballage__c, Cart.Account.Frais_autorisations__c, TotalLineAmount, TotalPrice, Quantity
            FROM CartItem 
            WHERE CartId = :cartId];
        
        if (cartItems.isEmpty()) {
            throw new B2BCheckoutTaxesException('No Cart Items were found (Cart Id: ' + cartId + ')');
        }
        return cartItems;
    }
    
    private static Frais__c getFrais(Id fraisId) {
        List<Frais__c> frais = [
            SELECT Id , Zone_territoriale__c
            FROM Frais__c 
            WHERE Id = :fraisId];
        
        if (frais.isEmpty()) {
            throw new B2BCheckoutTaxesException('No Frais__c record was found');
        } 
        
        return frais[0];
    }
    
    private static Map<String, Taxes__c> getTaxesByCodeTVA(String zoneCode, Set<String> tvaCodes) {
        List<Taxes__c> taxes = [
            SELECT Id, Zone_territoriale__c, Code_TVA__c, Taux_de_TVA__c
            FROM Taxes__c
            WHERE Zone_territoriale__c = :zoneCode
            AND Code_TVA__c IN :tvaCodes];
        
        Map<String, Taxes__c> taxesByCodeTVA = new Map<String, Taxes__c>();
        for (Taxes__c tax : taxes) {
            taxesByCodeTVA.put(tax.Code_TVA__c, tax);
        }
        
        return taxesByCodeTVA;
    }
    
    private static Map<String, Taxe_Emballage__c>  getTaxesConsigneByCodeEmballage(Set<String> codesEmballage){
        List<Taxe_Emballage__c> taxes = [
            SELECT Id, Name, Code_TVA__c, Code_emballage__c, Libelle_emballage__c, Nombre_d_UVC__c, Prix_consigne_emballage__c
            FROM Taxe_Emballage__c
            WHERE Code_emballage__c IN :codesEmballage];
        
        Map<String, Taxe_Emballage__c> taxesByCodeEmballage = new Map<String, Taxe_Emballage__c>();
        for (Taxe_Emballage__c tax : taxes) {
            taxesByCodeEmballage.put(tax.Code_emballage__c, tax);
        }
        
        return taxesByCodeEmballage;
    }
    
    
    private static Map<Id, CartTax> getCartTaxesByCartItemId(Set<Id> cartItemIds) {
        List<CartTax> cTaxes = Queries.getCartTaxes(cartItemIds);
        Map<Id, CartTax> cartTaxesByCartItemId = new Map<Id, CartTax>();
        for (CartTax cartTax : cTaxes) {
            cartTaxesByCartItemId.put(cartTax.CartItemId, cartTax);
        }
        
        return cartTaxesByCartItemId;
    }
    
    private static Map<Id, List<CartTax>> getCartTaxesByCartItemIdAndType(Set<Id> cartItemIds, List<String> taxNames) {
        
        List<CartTax> cartTaxes = new List<CartTax>([
            SELECT Id, Name, CartId, CartItemId, Amount, TaxRate, TaxType, TaxCalculationDate 
            FROM CartTax 
            WHERE CartItemId IN :cartItemIds and Name IN :taxNames]);
        
        Map<Id, List<CartTax>> cartTaxesByCartItemId = new Map<Id, List<CartTax>>();
        for (CartTax cartTax : cartTaxes) {
            if(cartTaxesByCartItemId.get(cartTax.CartItemId) == null)
            {
                List<CartTax> cartTaxesList = new List<CartTax>();
                cartTaxesList.add(cartTax);
                cartTaxesByCartItemId.put(cartTax.CartItemId, cartTaxesList);
            }else{
                
                List<CartTax> cartTaxesList = cartTaxesByCartItemId.get(cartTax.CartItemId);
                cartTaxesList.add(cartTax);
                cartTaxesByCartItemId.put(cartTax.CartItemId, cartTaxesList);
            }
            
        }
        
        return cartTaxesByCartItemId;
    }
    
    private static Map<Id, CartTax> getFilteredCartTaxesByType(Map<Id, CartTax> cartTaxes, String taxName) {
        if(cartTaxes == null) {
            return new Map<Id, CartTax>();
        }
        Map<Id, CartTax> cartTaxesByCartItemId = new Map<Id, CartTax>();
        
        for (CartTax cartTax : cartTaxes.values()) {
            if(cartTax.Name == taxName){
                cartTaxesByCartItemId.put(cartTax.CartItemId, cartTax);
            }
        }
        
        return cartTaxesByCartItemId;
    }
    
    @AuraEnabled(cacheable=true)
    public static Decimal getTaxeEmballageUnitaire(Id productId) {
        Decimal taxeEmballageUnitaire =0;
        String codeEmballage = [SELECT Id, Name, Code_emballage__c FROM Product2 where Id=:productId][0].Code_emballage__c;
        if(codeEmballage != null && codeEmballage != '')
        {
            List<Taxe_Emballage__c> te= [SELECT Id, Name, Code_emballage__c, Prix_consigne_emballage__c FROM Taxe_Emballage__c where Code_emballage__c =:codeEmballage ];
            if(te!=null && !te.isEmpty())
            {
                taxeEmballageUnitaire= te[0].Prix_consigne_emballage__c;
            }
        } 
        return taxeEmballageUnitaire;
    }
    
    
    public class B2BCheckoutTaxesException extends Exception {}
}