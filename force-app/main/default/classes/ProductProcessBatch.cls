public class ProductProcessBatch implements Database.Batchable<sObject> {
    String query='';
   
    public ProductProcessBatch(String query){
        if(query!=''){
           this.query=query;
        }else {
            this.query='select Id,Name,Part_Number__c,Active__c,Product__c from SQX_Part__c';
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
     }
    
    public void execute(Database.BatchableContext BC, List<SQX_Part__c> partsList){
         List<String> partNameList=new List<String>();
         List<String> partCodeList=new List<String>();
           
            for(SQX_Part__c part:partsList){
                partNameList.add(part.Name);
                partCodeList.add(part.Part_Number__c);
               
            }
        List<Product2> productList=[select Id,Name,ProductCode from Product2 where Name IN :partNameList and ProductCode IN :partCodeList];
        Map<String, Product2> productMap=new  Map<String, Product2>();
        for(Product2 product:productList){
           productMap.put(product.Name+product.ProductCode, product);
        }
        List<SQX_Part__c> updatedPartsList=new List<SQX_Part__c>();
        Map<Id, Product2> product2InsertMap=new Map<Id, Product2>();
        for(SQX_Part__c part:partsList){
            Product2 matchedProduct=productMap.get(part.Name+part.Part_Number__c);
            if(matchedProduct!=null && part.Product__c==null){
                    part.Product__c=matchedProduct.Id;
                    updatedPartsList.add( part);
            }else{
                Product2 product2Insert= new Product2();
                product2Insert.Name=part.Name;
                product2Insert.ProductCode=part.Part_Number__c;
                product2InsertMap.put(part.Id, product2Insert);
            }
        }
        
       
        
         if(!product2InsertMap.isEmpty() &&!product2InsertMap.values().isEmpty()){
            insert product2InsertMap.values();
             for(Id partId:product2InsertMap.keySet()){
                 Product2 ProductMatched=product2InsertMap.get(partId);
                 SQX_Part__c part=new SQX_Part__c();
                 part.Id=partId;
                 part.Product__c=ProductMatched.Id;
                 updatedPartsList.add(part);
             }
         }
        
       
        
         if(!updatedPartsList.isEmpty()){
           update updatedPartsList;
        }
    }

   public void finish(Database.BatchableContext BC){
   }
}