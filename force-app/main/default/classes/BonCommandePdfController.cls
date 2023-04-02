public without sharing class BonCommandePdfController {
    public static Order orderTrueValue{get; set;}
    public static Order orderFalseValue{get; set;}
    
    public static list<livraison> lists = new list<livraison>();
    public static List<BonPreparationWr> commandes = new List<BonPreparationWr>();
       
    public static list<BonPreparationWr> getCommandes() {return commandes;}
	
    @AuraEnabled(cacheable=false)
    public static void initData() {
        String selectedOrdersString = ApexPages.currentPage().getParameters().get('selectedOrders');
        String selectedRayonsString = ApexPages.currentPage().getParameters().get('selectedRayons');
        String inclureImagesString = ApexPages.currentPage().getParameters().get('inclureimage');
        
        if(selectedOrdersString != null && selectedOrdersString != '') {
            List<Id> idsOrders = selectedOrdersString.split(',');
                        Boolean inclureImage = false;
            if(inclureImagesString == 'true')
                inclureImage = true;
            Set<String> rayons = null;
            if(selectedRayonsString != null && selectedRayonsString != '') {
                List<String> rayonsList = selectedRayonsString.split(',');
                rayons = new Set<String>();
                for(String ray: rayonsList) {
                    rayons.add(ray);
                }
            }
            
            commandes = BonCommandeService.constructJSON(idsOrders, rayons, inclureImage);
        }
                                
        orderTrueValue = new Order(IsReductionOrder = true);
        orderFalseValue = new Order(IsReductionOrder = false);
    }
    
    public BonCommandePdfController() {
        
    }
    
    
    public class BonPreparationWr {
        public Boolean withProductPicture{get; set;}
        public String numCommande{get; set;}
        public String numClient{get; set;}
        public String raisonSociale{get; set;}
        public Double montantTotalTTC{get; set;}
        public String contact{get; set;}
        public String paiement{get; set;}
        public String commentaires{get; set;}
        public String cssClass{get; set;}
        public Integer nombreProduits{get; set;}
        public Integer nombreReferences{get; set;}
        public Livraison livraison{get; set;}
        public List<RayonsSelectionne> rayonsSelectionnes{get; set;}
        //public Map<String, Boolean> rayonsSelectionnes{get; set;}
        public List<OrderItemWr> orderItems{get; set;}
    }
    
    public class Livraison {
        public String modeRetrait{get; set;}
        public String dateLivraison{get; set;}
        public String heureDebut{get; set;}
        public String heureFin{get; set;}
    }
    
    public class RayonsSelectionne {
        public String name{get; set;}
        public boolean selected{get; set;}
    }
    
    public class OrderItemWr {
        public String rayon{get; set;}
        public String codeRayon{get; set;}
        public String backgroundColor{get; set;}
        public List<ProductWr> products{get; set;}
    }
    
    public class ProductWr {
        public String image{get; set;}
        public String name{get; set;}
        public String conditionnement{get; set;}
        public String ifls{get; set;}
        public Double prixHT{get; set;}
        public Decimal quantity{get; set;}
        public String cssClass{get; set;}
    }
}