public without sharing class OrdersController {
    private ApexPages.StandardSetController standardController;
    public boolean inclureimage {get;set;}
    String[] rayons = new String[]{};
    public static Map<String, String> libelleRayonByCode = new Map<String, String>();
    public Boolean imprimerDisabled {get; set;}
    
    public OrdersController(ApexPages.StandardSetController standardController) {
        this.standardController = standardController;
        List<Order> selectedOrders = (List<Order>) standardController.getSelected();
        if (selectedOrders != null && selectedOrders.size() > 0) {
            imprimerDisabled = false;
        } else {
            imprimerDisabled = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Veuillez selectionner des orders'));
        }
            
    }
    
    public List<SelectOption> getItems() {
        List<LibelleRayon__mdt> libRayonByCodeMdt = [SELECT Code__c, Label FROM LibelleRayon__mdt];
        for (LibelleRayon__mdt libRayonByCde : libRayonByCodeMdt) {
            libelleRayonByCode.put(libRayonByCde.Code__c, libRayonByCde.Label);
        }

        List<SelectOption> options = new List<SelectOption>();
        for (String key: libelleRayonByCode.keySet()) {
            options.add(new SelectOption(key, libelleRayonByCode.get(key)));
        }
        return options;
    }
    
    public String[] getRayons() {
        return rayons;
    }
 
    public void setRayons(String[] rayons) {
        this.rayons = rayons;
    }
    
    public PageReference imprimer() {
        PageReference pdfPage = new PageReference('/apex/BonCommandePdf');
        pdfPage.getParameters().put('selectedOrders',getSelectedOrdersIdsParam((List<Order>) standardController.getSelected()));
        pdfPage.getParameters().put('selectedRayons',getSelectedRayonsParam());
        pdfPage.getParameters().put('inclureimage',inclureimage+'');
        pdfPage.setRedirect(true);
        return pdfPage;
    }
    
    private String getSelectedOrdersIdsParam(List<Order> orders) {
        String res = '';
        for(Order o: orders) {
            res += o.Id + ',';
        }
        return res;
    }
    
    private String getSelectedRayonsParam() {
        String res = '';
        for(String s: rayons) {
            res += s + ',';
        }
        return res;
    }
}