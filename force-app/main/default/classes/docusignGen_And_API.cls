public class docusignGen_And_API {
    @InvocableMethod(label='docusignGen_And_API')
    public static List<String> sendEnvelope(List<String> record) {
        System.debug(record);  
        Id recordId = record[0];
        System.debug(recordId);
        gen_and_convert(recordId);
        return Null;
    }    
    
    @future(callout = true)  
    public static void gen_and_convert(Id recordId){
        String jsonBody = bodyJSON(recordId);  // Create the message body for DocuSign endpoint /restapi/v2.1/accounts/{accountId}/envelopes/generate_and_convert
        System.debug(jsonBody); 
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:DocuSign_eSign/restapi/v2.1/accounts/18754407/envelopes/generate_and_convert'); // API call to DocuSign endpoint 
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        req.setBody(jsonBody); // Grab record data and template for API call
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody(); // Generated document as base64
        System.debug(responseBody); 
        
        Blob blobContent = EncodingUtil.base64Decode(responseBody);
        
        DateTime now = System.now();
        String s = string.valueof(now); // Get current date/time   
        
        // Save generated document to Files
        ContentVersion v = new ContentVersion();
        v.VersionData = blobContent;
        v.Title = 'Devis '+ s;
        v.PathOnClient ='docusignGen_And_API.docx';
        insert v;
        
        v = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: v.Id];
        ContentDocumentLink objCDL = new ContentDocumentLink(
            ContentDocumentId = v.ContentDocumentId,
            LinkedEntityId = recordId,
            Visibility = 'AllUsers'
        );
        
        insert objCDL;         
    }  
    
    public static String bodyJSON(Id recordId){
        SBQQ__Quote__c quote = [SELECT Id, EntiteFromOppty__c FROM SBQQ__Quote__c WHERE Id =: recordId];
        ContentVersion file = new ContentVersion();
        
        if(quote.EntiteFromOppty__c == 'Soleil et Climat' ){
            file = [SELECT VersionData FROM ContentVersion WHERE IsLatest = TRUE AND ContentDocumentId  = '069Aa000008V47ZIAS' LIMIT 1]; 
        }else if(quote.EntiteFromOppty__c == 'Chauffage et Climat'){
            file = [SELECT VersionData FROM ContentVersion WHERE IsLatest = TRUE AND ContentDocumentId  = '069Aa000008UbqNIAS' LIMIT 1]; 
        }else if(quote.EntiteFromOppty__c == 'Façades et Climat'){
            file = [SELECT VersionData FROM ContentVersion WHERE IsLatest = TRUE AND ContentDocumentId  = '069Aa000008VrHxIAK' LIMIT 1]; 
        }
        // Grab the template document and convert into base64 Blob for document generation body
        //ContentVersion file = [SELECT VersionData FROM ContentVersion WHERE IsLatest = TRUE AND ContentDocumentId  = '069Aa000008UbqNIAS' LIMIT 1];
        Blob fileBlob = file.VersionData;           
        String fileBase64 = EncodingUtil.base64Encode(fileBlob);       
        
        // Create the JSON body for the Document Generation API call
        JSONGenerator jsGen = SYSTEM.JSON.createGenerator(true);
        jsGen.writeStartObject();  
        jsGen.writeFieldName('generateProperties');
        jsGen.writeStartArray(); 
        jsGen.writeStartObject(); 
        jsGen.writeStringField('dataJson', quoteRecord(recordId));  // Record Data
        jsGen.writeBlobField('base64GenerateTemplateDocument', fileBlob);  // Template Document
        jsGen.writeStringField('archiveDocumentType', 'DOCX');  // Response document type which can be XHTML, PDF, or DOCX
        jsGen.writeEndObject(); 
        jsGen.writeEndArray(); 
        jsGen.writeEndObject();
        String jsonData = jsGen.getAsString();
        return jsonData;
    }      
    
    public static String quoteRecord(Id recordId) {
        String NeedTVA = '';
        String jsonData = '';
        // Fetching the necessary fields from the SBQQ__Quote__c object
        SBQQ__Quote__c quoteRec = [	SELECT Name, SBQQ__StartDate__c, SBQQ__PrimaryContact__r.LastName,
                                   SBQQ__PrimaryContact__r.FirstName, SBQQ__PrimaryContact__r.Phone, 
                                   SBQQ__PrimaryContact__r.Email,SBQQ__BillingStreet__c,SBQQ__BillingPostalCode__c,
                                   SBQQ__BillingCity__c,SBQQ__ShippingStreet__c,SBQQ__ShippingPostalCode__c,
                                   SBQQ__ShippingCity__c,SBQQ__SalesRep__r.FirstName,SBQQ__SalesRep__r.LastName,
                                   SBQQ__SalesRep__r.MobilePhone,AlimentationElectriqueDuSite__c,PuissanceGlobaleDeLinstallation__c,
                                   TECH_InstallationAutoReventeSurplus__c,TECH_InstallationAutoStockageVirtuel__c,
                                   TECH_InstallationReventeTotale__c,MontantApport__c,TECH_NetAmount__c,
                                   TECH_TVA_55__c,TECH_TVA10__c,TECH_TVA20__c,TECH_PrixTotalTTC__c,
                                   TECH_MontantAcompte__c,TECH_MontantFinance__c,TECH_SoldeApresAcompte__c,
                                   TECH_MontantMensualites__c,TECH_MontantTotalDu__c,MontantTotalPrimeCEE_ForQT__c,
                                   TECH_MontantTotalMPR__c,MontantTotalNetApresPrimesForQT__c,DureeContratMois__c,
                                   NombreMensualites__c,TAEG__c,TauxDebiteur__c,TECH_DateJour__c, 
                                   TypeFormuleSC__c,TypeAppareilExistantFromOppty__c,ModeleAppareilExistantFromOppty__c,
                                   MarqueAppareilExistantFromOppty__c,NombrePersonnesAuFoyerFromOppty__c,
                                   TrancheRessourceFromOppty__c,SurfaceChauffeem2FromOppty__c,DateDeConstructionFromOppty__c,
                                   NumeroDeParcelleFromOppty__c,TypeDeLogementFromOppty__c,CHECK_MontantTotalPrimeCEE__c,
                                   CHECK_MontantTotalMPR__c,CHECK_MPRGreaterThan0__c,CHECK_Comptant__c,
                                   CHECK_Financement__c,CHECK_TauxTvaNotEquals20__c,Delegataire__c,TECH_AvecReport6mois__c, 
                                   CHECK_Carports__c, TypeDeChauffageFromOppty__c, SBQQ__ExpirationDate__c, TECH_MontantTotalPrimeCEE__c, 
                                   MontantTotalPrimeCEE__c, CHECK_AdditionalDiscountGreaterThan0__c
                                   FROM SBQQ__Quote__c 
                                   WHERE Id = :recordId 
                                   LIMIT 1];
        try{
            JSONGenerator jsGen = System.JSON.createGenerator(true);
            jsGen.writeStartObject();
            jsGen.writeFieldName('Quote');
            jsGen.writeStartObject();
            if(quoteRec.CHECK_TauxTvaNotEquals20__c == true){
                NeedTVA = 'True';
            }else if(quoteRec.CHECK_TauxTvaNotEquals20__c == false){
                NeedTVA = 'False';
            }
            jsGen.writeStringField('CHECK_AdditionalDiscountGreaterThan0__c', quoteRec.CHECK_AdditionalDiscountGreaterThan0__c != null ? quoteRec.CHECK_AdditionalDiscountGreaterThan0__c : 'False');
            jsGen.writeNumberField('MontantTotalPrimeCEE__c', quoteRec.MontantTotalPrimeCEE__c != null ? quoteRec.MontantTotalPrimeCEE__c : 0);
            jsGen.writeStringField('TECH_MontantTotalPrimeCEE__c', quoteRec.TECH_MontantTotalPrimeCEE__c != null ? quoteRec.TECH_MontantTotalPrimeCEE__c : '');
            jsGen.writeDateField('SBQQ__ExpirationDate__c', quoteRec.SBQQ__ExpirationDate__c != null ? quoteRec.SBQQ__ExpirationDate__c : Date.newInstance(2024, 9, 5));
            jsGen.writeStringField('TypeDeChauffageFromOppty__c', quoteRec.TypeDeChauffageFromOppty__c != null ? quoteRec.TypeDeChauffageFromOppty__c : '');
            jsGen.writeStringField('CHECK_Carports__c', quoteRec.CHECK_Carports__c);
            jsGen.writeStringField('CHECK_TauxTvaNotEquals20__c', NeedTVA);
            jsGen.writeStringField('Delegataire__c', quoteRec.Delegataire__c != null ? quoteRec.Delegataire__c : '');
            jsGen.writeStringField('CHECK_MontantTotalPrimeCEE__c', quoteRec.CHECK_MontantTotalPrimeCEE__c != null ? quoteRec.CHECK_MontantTotalPrimeCEE__c : '');
            jsGen.writeStringField('CHECK_MontantTotalMPR__c', quoteRec.CHECK_MontantTotalMPR__c != null ? quoteRec.CHECK_MontantTotalMPR__c : '');
            jsGen.writeStringField('CHECK_MPRGreaterThan0__c', quoteRec.CHECK_MPRGreaterThan0__c != null ? quoteRec.CHECK_MPRGreaterThan0__c : '');
            jsGen.writeNumberField('MontantTotalPrimeCEE_ForQT__c', quoteRec.MontantTotalPrimeCEE_ForQT__c != null ? quoteRec.MontantTotalPrimeCEE_ForQT__c : 0);
            jsGen.writeStringField('TECH_MontantTotalMPR__c', quoteRec.TECH_MontantTotalMPR__c != null ? quoteRec.TECH_MontantTotalMPR__c : '');
            jsGen.writeNumberField('MontantTotalNetApresPrimesForQT__c', quoteRec.MontantTotalNetApresPrimesForQT__c != null ? quoteRec.MontantTotalNetApresPrimesForQT__c : 0);
            jsGen.writeStringField('TECH_TVA_55__c', quoteRec.TECH_TVA_55__c != null ? quoteRec.TECH_TVA_55__c : '');
            jsGen.writeNumberField('NombrePersonnesAuFoyerFromOppty__c', quoteRec.NombrePersonnesAuFoyerFromOppty__c != null ? quoteRec.NombrePersonnesAuFoyerFromOppty__c : 0);
            jsGen.writeStringField('TrancheRessourceFromOppty__c', quoteRec.TrancheRessourceFromOppty__c != null ? quoteRec.TrancheRessourceFromOppty__c : '');
            jsGen.writeNumberField('SurfaceChauffeem2FromOppty__c', quoteRec.SurfaceChauffeem2FromOppty__c != null ? quoteRec.SurfaceChauffeem2FromOppty__c : 0);
            jsGen.writeDateField('DateDeConstructionFromOppty__c', quoteRec.DateDeConstructionFromOppty__c != null ? quoteRec.DateDeConstructionFromOppty__c : Date.newInstance(2024, 9, 5));
            jsGen.writeStringField('NumeroDeParcelleFromOppty__c', quoteRec.NumeroDeParcelleFromOppty__c != null ? quoteRec.NumeroDeParcelleFromOppty__c : '');
            jsGen.writeStringField('TypeDeLogementFromOppty__c', quoteRec.TypeDeLogementFromOppty__c != null ? quoteRec.TypeDeLogementFromOppty__c : '');
            jsGen.writeStringField('TypeAppareilExistantFromOppty__c', quoteRec.TypeAppareilExistantFromOppty__c != null ? quoteRec.TypeAppareilExistantFromOppty__c : '');
            jsGen.writeStringField('ModeleAppareilExistantFromOppty__c', quoteRec.ModeleAppareilExistantFromOppty__c != null ? quoteRec.ModeleAppareilExistantFromOppty__c : '');
            jsGen.writeStringField('MarqueAppareilExistantFromOppty__c', quoteRec.MarqueAppareilExistantFromOppty__c != null ? quoteRec.MarqueAppareilExistantFromOppty__c : '');
            jsGen.writeStringField('Name', quoteRec.Name != null ? quoteRec.Name : '');
            jsGen.writeStringField('TypeFormuleSC__c', quoteRec.TypeFormuleSC__c != null ? quoteRec.TypeFormuleSC__c : '');
            jsGen.writeDateField('SBQQ__StartDate__c', quoteRec.SBQQ__StartDate__c != null ? quoteRec.SBQQ__StartDate__c : Date.newInstance(2024, 9, 5));
            jsGen.writeStringField('SBQQ__PrimaryContact__r.LastName', quoteRec.SBQQ__PrimaryContact__r.LastName != null ? quoteRec.SBQQ__PrimaryContact__r.LastName : '');
            jsGen.writeStringField('SBQQ__PrimaryContact__r.FirstName', quoteRec.SBQQ__PrimaryContact__r.FirstName != null ? quoteRec.SBQQ__PrimaryContact__r.FirstName : '');
            jsGen.writeStringField('SBQQ__PrimaryContact__r.Phone', quoteRec.SBQQ__PrimaryContact__r.Phone != null ? quoteRec.SBQQ__PrimaryContact__r.Phone : '');
            jsGen.writeStringField('SBQQ__PrimaryContact__r.Email', quoteRec.SBQQ__PrimaryContact__r.Email != null ? quoteRec.SBQQ__PrimaryContact__r.Email : '');
            jsGen.writeStringField('SBQQ__BillingStreet__c', quoteRec.SBQQ__BillingStreet__c != null ? quoteRec.SBQQ__BillingStreet__c : '');
            jsGen.writeStringField('SBQQ__BillingPostalCode__c', quoteRec.SBQQ__BillingPostalCode__c != null ? quoteRec.SBQQ__BillingPostalCode__c : '');
            jsGen.writeStringField('SBQQ__BillingCity__c', quoteRec.SBQQ__BillingCity__c != null ? quoteRec.SBQQ__BillingCity__c : '');
            jsGen.writeStringField('SBQQ__ShippingStreet__c', quoteRec.SBQQ__ShippingStreet__c != null ? quoteRec.SBQQ__ShippingStreet__c : '');
            jsGen.writeStringField('SBQQ__ShippingPostalCode__c', quoteRec.SBQQ__ShippingPostalCode__c != null ? quoteRec.SBQQ__ShippingPostalCode__c : '');
            jsGen.writeStringField('SBQQ__ShippingCity__c', quoteRec.SBQQ__ShippingCity__c != null ? quoteRec.SBQQ__ShippingCity__c : '');
            jsGen.writeStringField('SBQQ__SalesRep__r.FirstName', quoteRec.SBQQ__SalesRep__r.FirstName != null ? quoteRec.SBQQ__SalesRep__r.FirstName : '');
            jsGen.writeStringField('SBQQ__SalesRep__r.LastName', quoteRec.SBQQ__SalesRep__r.LastName != null ? quoteRec.SBQQ__SalesRep__r.LastName : '');
            jsGen.writeStringField('SBQQ__SalesRep__r.MobilePhone', quoteRec.SBQQ__SalesRep__r.MobilePhone != null ? quoteRec.SBQQ__SalesRep__r.MobilePhone : '');
            jsGen.writeStringField('AlimentationElectriqueDuSite__c', quoteRec.AlimentationElectriqueDuSite__c != null ? quoteRec.AlimentationElectriqueDuSite__c : '');
            jsGen.writeNumberField('PuissanceGlobaleDeLinstallation__c', quoteRec.PuissanceGlobaleDeLinstallation__c != null ? quoteRec.PuissanceGlobaleDeLinstallation__c : 0);
            jsGen.writeStringField('TECH_InstallationAutoReventeSurplus__c', quoteRec.TECH_InstallationAutoReventeSurplus__c != null ? quoteRec.TECH_InstallationAutoReventeSurplus__c : '');
            jsGen.writeStringField('TECH_InstallationAutoStockageVirtuel__c', quoteRec.TECH_InstallationAutoStockageVirtuel__c != null ? quoteRec.TECH_InstallationAutoStockageVirtuel__c : '');
            jsGen.writeStringField('TECH_InstallationReventeTotale__c', quoteRec.TECH_InstallationReventeTotale__c != null ? quoteRec.TECH_InstallationReventeTotale__c : '');
            jsGen.writeStringField('TECH_NetAmount__c', quoteRec.TECH_NetAmount__c != null ? quoteRec.TECH_NetAmount__c : '');
            jsGen.writeStringField('TECH_TVA10__c', quoteRec.TECH_TVA10__c != null ? quoteRec.TECH_TVA10__c : '');
            jsGen.writeStringField('TECH_TVA20__c', quoteRec.TECH_TVA20__c != null ? quoteRec.TECH_TVA20__c : '');
            jsGen.writeStringField('TECH_PrixTotalTTC__c', quoteRec.TECH_PrixTotalTTC__c != null ? quoteRec.TECH_PrixTotalTTC__c : '');
            jsGen.writeStringField('TECH_MontantAcompte__c', quoteRec.TECH_MontantAcompte__c != null ? quoteRec.TECH_MontantAcompte__c : '');
            jsGen.writeStringField('CHECK_Comptant__c', quoteRec.CHECK_Comptant__c != null ? quoteRec.CHECK_Comptant__c : '');
            jsGen.writeStringField('TECH_SoldeApresAcompte__c', quoteRec.TECH_SoldeApresAcompte__c != null ? quoteRec.TECH_SoldeApresAcompte__c : '');
            jsGen.writeStringField('CHECK_Financement__c', quoteRec.CHECK_Financement__c != null ? quoteRec.CHECK_Financement__c : '');
            jsGen.writeNumberField('MontantApport__c', quoteRec.MontantApport__c != null ? quoteRec.MontantApport__c : 0);
            jsGen.writeStringField('TECH_MontantFinance__c', quoteRec.TECH_MontantFinance__c != null ? quoteRec.TECH_MontantFinance__c : '');
            jsGen.writeNumberField('DureeContratMois__c', quoteRec.DureeContratMois__c != null ? quoteRec.DureeContratMois__c : 0);
            jsGen.writeNumberField('NombreMensualites__c', quoteRec.NombreMensualites__c != null ? quoteRec.NombreMensualites__c : 0);
            jsGen.writeStringField('TECH_MontantMensualites__c', quoteRec.TECH_MontantMensualites__c != null ? quoteRec.TECH_MontantMensualites__c : '');
            jsGen.writeStringField('TECH_MontantTotalDu__c', quoteRec.TECH_MontantTotalDu__c != null ? quoteRec.TECH_MontantTotalDu__c : '');
            jsGen.writeNumberField('TAEG__c', quoteRec.TAEG__c != null ? quoteRec.TAEG__c : 0);
            jsGen.writeNumberField('TauxDebiteur__c', quoteRec.TauxDebiteur__c != null ? quoteRec.TauxDebiteur__c : 0);
            jsGen.writeStringField('TECH_DateJour__c', quoteRec.TECH_DateJour__c != null ? quoteRec.TECH_DateJour__c : '');
            jsGen.writeStringField('TECH_AvecReport6mois__c', quoteRec.TECH_AvecReport6mois__c != null ? quoteRec.TECH_AvecReport6mois__c : '');
            jsGen.writeEndObject(); // End Quote object
            
            // QuoteLineItems
            jsGen.writeFieldName('QuoteLineItems');
            jsGen.writeStartArray();
            for(SBQQ__QuoteLine__c quoteLines : [SELECT Id,SBQQ__Product__r.Name,SBQQ__Description__c,SBQQ__Quantity__c, 
                                                 TECH_NetTotal__c,FamilleDeProduit__c,DesignationEtCaracteristiquesCC__c,
                                                 TECH_ListPrice__c,TECH_SBQQ_AdditionalDiscount__c, SBQQ__ProductFamily__c,
                                                 Type__c, SBQQ__ProductName__c, TECH_QTY_UNIT__c 
                                                 FROM SBQQ__QuoteLine__c 
                                                 WHERE SBQQ__Quote__c = :recordId]){
                                                     jsGen.writeStartObject();
                                                     jsGen.writeStringField('Id', quoteLines.Id != null ? quoteLines.Id : '');
                                                     jsGen.writeStringField('SBQQ__Product__r.Name', quoteLines.SBQQ__Product__r.Name != null ? quoteLines.SBQQ__Product__r.Name : '');
                                                     jsGen.writeStringField('SBQQ__Description__c', quoteLines.SBQQ__Description__c != null ? quoteLines.SBQQ__Description__c : '');
                                                     jsGen.writeNumberField('SBQQ__Quantity__c', quoteLines.SBQQ__Quantity__c != null ? quoteLines.SBQQ__Quantity__c : 0);
                                                     jsGen.writeStringField('TECH_NetTotal__c', quoteLines.TECH_NetTotal__c != null ? quoteLines.TECH_NetTotal__c : '');
                                                     jsGen.writeStringField('DesignationEtCaracteristiquesCC__c', quoteLines.DesignationEtCaracteristiquesCC__c != null ? quoteLines.DesignationEtCaracteristiquesCC__c : '');
                                                     jsGen.writeStringField('TECH_ListPrice__c', quoteLines.TECH_ListPrice__c != null ? quoteLines.TECH_ListPrice__c : '');
                                                     jsGen.writeStringField('TECH_SBQQ_AdditionalDiscount__c', quoteLines.TECH_SBQQ_AdditionalDiscount__c != null ? quoteLines.TECH_SBQQ_AdditionalDiscount__c : '');
                                                     jsGen.writeStringField('FamilleDeProduit__c', quoteLines.FamilleDeProduit__c != null ? quoteLines.FamilleDeProduit__c : '');
                                                     jsGen.writeStringField('SBQQ__ProductFamily__c', quoteLines.SBQQ__ProductFamily__c != null ? quoteLines.SBQQ__ProductFamily__c : '');
                                                     
                                                     jsGen.writeStringField('TECH_QTY_UNIT__c', quoteLines.TECH_QTY_UNIT__c != null ? quoteLines.TECH_QTY_UNIT__c : '');
                                                     
                                                     jsGen.writeStringField('Type__c', quoteLines.Type__c != null ? quoteLines.Type__c : '');
                                                     jsGen.writeStringField('SBQQ__ProductName__c', quoteLines.SBQQ__ProductName__c != null ? quoteLines.SBQQ__ProductName__c : '');
                                                     jsGen.writeEndObject();
                                                 }
            jsGen.writeEndArray(); 
            // End QuoteLineItems array
            
            jsGen.writeEndObject(); // End Root object
            
            jsonData = jsGen.getAsString();
            System.debug('JSON Data: ' + jsonData);
            
        }catch(Exception e){
            System.debug(e);
        } 
        return jsonData;
    }
}