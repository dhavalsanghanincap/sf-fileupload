@isTest
public class Test_Base311_Attribute {
    @isTest
    static void testFromSQ() {
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Case c = Test_RestTestHelper.serviceRequest(stv.Id);
        Question__c q = Test_RestTestHelper.question();
        Service_Type_Version_Question__c stvq = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv.Id);
    Service_Question__c sq = Test_RestTestHelper.serviceQuestion(c.Id, stvq.Id);
        sq.Answer__c = '123';
        Base311_Attribute attr = Base311_Attribute.fromSQ(sq);
        System.assertEquals(attr.value, '123');
    }
    
    @isTest
    static void testValidationNoSTVQ() {
        Base311_Attribute attr = new Base311_Attribute('abc', 123);
        attr.validation();
        System.assertEquals(attr.errors.size(), 1);
        System.assertEquals(attr.errors[0], 'Unknown question abc');
    }
    
    @isTest
    static void testValidationRequired() {
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Case c = Test_RestTestHelper.serviceRequest(stv.Id);
        Question__c q = Test_RestTestHelper.question();
        q.Question__c = 'Some test label';
        update q;
        Service_Type_Version_Question__c stvq = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv.Id);
        stvq.Is_Required__c = true;
        update stvq;
        
        Base311_Service_ServiceType sst = new Base311_Service_ServiceType();
        
        stv = sst.getServiceType(stv.Name, true);
        
    Service_Question__c sq = Test_RestTestHelper.serviceQuestion(c.Id, stvq.Id);
        stvq = stv.Service_Type_Version_Questions__r[0];
        
        Base311_Attribute attr = new Base311_Attribute(stvq.Question__r.Flex_Question_Code__c, null, stvq);
        attr.validation();
        System.assertEquals(attr.errors.size(), 1);
        System.assertEquals(attr.errors[0], '"Some test label" (' + stvq.Question__r.Flex_Question_Code__c + ')' +' is required');
    }
    
    @isTest
    static void testValidationPicklist() {
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Case c = Test_RestTestHelper.serviceRequest(stv.Id);
        Question__c q = Test_RestTestHelper.question();
        q.Data_Type__c = 'Picklist';
        q.Question__c = 'Some test label';
        update q;
        Service_Type_Version_Question__c stvq = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv.Id);
        stvq.Override_Answer_Values__c = '[{"key":"abc", "value":"DEF"}, {"key":"123", "value":456}]';
        update stvq;
        
        Base311_Service_ServiceType sst = new Base311_Service_ServiceType();
        stv = sst.getServiceType(stv.Name, true);
        
    Service_Question__c sq = Test_RestTestHelper.serviceQuestion(c.Id, stvq.Id);
        stvq = stv.Service_Type_Version_Questions__r[0];
        
        Base311_Attribute attr = new Base311_Attribute(stvq.Question__r.Flex_Question_Code__c, 'dne', stvq);
        attr.validation();
        System.assertEquals(attr.errors.size(), 1);
        System.assertEquals(attr.errors[0], '"Some test label" (' + stvq.Question__r.Flex_Question_Code__c + ')' +' is limited to one of abc, 123');
    }
    
@isTest
    static void testFromMap() {
        Map<String, Object> items = new Map<String, Object>{
            'ABC' => 123
        };
            
        Map<String, Base311_Attribute> mapped = Base311_Attribute.fromMap(items);
        
        System.assert(mapped.containsKey('ABC'));
        System.assertEquals((Integer) mapped.get('ABC').value, 123);
}
    
    @isTest
    static void testStringifyValue() {
        Question__c q = Test_RestTestHelper.question('', 'Text', '');
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Service_Type_Version_Question__c stvq = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv.Id);
        stvq.Override_Answer_Values__c = '[{"key":"BLK101", "value":"BLK101"}]';
        update stvq;
        stvq = [SELECT Name,  Question__r.Question__c, Question__r.Data_Type__c, Override_Answer_Values__c, Question__r.Flex_Question_Code__c  FROM Service_Type_Version_Question__c WHERE Id = :stvq.Id];
        Base311_Attribute ra = new Base311_Attribute(stvq.Question__r.Flex_Question_Code__c, 'BLK101', stvq);
        String val = ra.stringifyValue();
        System.assertEquals(val, 'BLK101');
    }
    
    @isTest
    static void testStringifyBool() {
        Question__c q = Test_RestTestHelper.question('', 'Boolean (checkbox)', '');
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Service_Type_Version_Question__c stvq = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv.Id);
        stvq.Override_Answer_Values__c = '[{"key":"BLK101", "value":"BLK101"}]';
        update stvq;
        stvq = [SELECT Name,  Question__r.Question__c, Question__r.Data_Type__c, Override_Answer_Values__c, Question__r.Flex_Question_Code__c  FROM Service_Type_Version_Question__c WHERE Id = :stvq.Id];
        Base311_Attribute ra = new Base311_Attribute(stvq.Question__r.Flex_Question_Code__c, true);
        String val = ra.stringifyValue();
        System.assertEquals(val, 'true');
    }
    
    @isTest
    static void testStringifyNumberDec() {
        Question__c q = Test_RestTestHelper.question('', 'Number', '');
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Service_Type_Version_Question__c stvq = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv.Id);
        stvq.Override_Answer_Values__c = '[{"key":"BLK101", "value":"BLK101"}]';
        update stvq;
        stvq = [SELECT Name, Question__r.Question__c,  Question__r.Data_Type__c, Override_Answer_Values__c, Question__r.Flex_Question_Code__c  FROM Service_Type_Version_Question__c WHERE Id = :stvq.Id];
        Base311_Attribute ra = new Base311_Attribute(stvq.Question__r.Flex_Question_Code__c, 5.1, stvq);
        String val = ra.stringifyValue();
        System.assertEquals(val, '5.1');
    }
    
    @isTest
    static void testStringifyNumberInt() {
        Question__c q = Test_RestTestHelper.question('', 'Number', '');
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Service_Type_Version_Question__c stvq = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv.Id);
        stvq.Override_Answer_Values__c = '[{"key":"BLK101", "value":"BLK101"}]';
        update stvq;
        stvq = [SELECT Name,  Question__r.Question__c, Question__r.Data_Type__c, Override_Answer_Values__c, Question__r.Flex_Question_Code__c  FROM Service_Type_Version_Question__c WHERE Id = :stvq.Id];
        Base311_Attribute ra = new Base311_Attribute(stvq.Question__r.Flex_Question_Code__c, 3, stvq);
        String val = ra.stringifyValue();
        System.assertEquals(val, '3');
    }
    
    @isTest
    static void testStringifyDateTime() {
       Datetime testdt = System.now();
        Question__c q = Test_RestTestHelper.question('', 'Date/Time', '');
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Service_Type_Version_Question__c stvq = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv.Id);
        stvq.Override_Answer_Values__c = '[{"key":"BLK101", "value":"BLK101"}]';
        update stvq;
        stvq = [
            SELECT Name, Question__r.Question__c,  Question__r.Data_Type__c, Override_Answer_Values__c, Question__r.Flex_Question_Code__c 
            FROM Service_Type_Version_Question__c 
            WHERE Id = :stvq.Id
        ];
        
        Base311_Attribute ra = new Base311_Attribute(stvq.Question__r.Flex_Question_Code__c, Base311_Helper.formatDate(testdt), stvq);
        String val = ra.stringifyValue();
        System.assertEquals(val, Base311_Helper.formatHumanDatetime(testdt));
    }
    
    @isTest
    static void testStringifyMulti() {
        Question__c q = Test_RestTestHelper.question('', 'MultiPicklist', '');
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Service_Type_Version_Question__c stvq = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv.Id);
        stvq.Override_Answer_Values__c = '[{"key":"BLK101", "value":"BLK101"},{"key":"RED101", "value":"RED101"}]';
        update stvq;
        stvq = [SELECT Name,  Question__r.Question__c, Question__r.Data_Type__c, Override_Answer_Values__c, Question__r.Flex_Question_Code__c  FROM Service_Type_Version_Question__c WHERE Id = :stvq.Id];
        
        Base311_Attribute ra = new Base311_Attribute(stvq.Question__r.Flex_Question_Code__c, new List<String>{ 'BLK101', 'RED101' }, stvq);
        
        String val = ra.stringifyValue();
        System.assertEquals(val, 'BLK101, RED101');
    }
    
    @isTest
    static void testStringifyMultiBad() {
        try{ 
            Question__c q = Test_RestTestHelper.question('', 'MultiPicklist', '');
            Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
            Service_Type_Version_Question__c stvq = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv.Id);
            stvq.Override_Answer_Values__c = '[{"key":"BLK101", "value":"BLK101"}]';
            update stvq;
        stvq = [SELECT Question__r.Question__c, Name, Question__r.Data_Type__c, Override_Answer_Values__c, Question__r.Flex_Question_Code__c  FROM Service_Type_Version_Question__c WHERE Id = :stvq.Id];
        Base311_Attribute ra = new Base311_Attribute(stvq.Question__r.Flex_Question_Code__c, new List<String>{ 'BLK101', 'GRN101' }, stvq);
            String val = ra.stringifyValue();
            System.assert(false);
        } catch(Base311_Exceptions.UnsupportedException e) {
            System.assert(true);
        }
    }
    
    @isTest
    static void testStringifySingle() { 
        Question__c q = Test_RestTestHelper.question('', 'MultiPicklist', '');
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Service_Type_Version_Question__c stvq = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv.Id);
        stvq.Override_Answer_Values__c = '[{"key":"BLK101", "value":"BLK101"}]';
        update stvq;
        stvq = [SELECT Name, Question__r.Data_Type__c, Override_Answer_Values__c, Question__r.Flex_Question_Code__c  FROM Service_Type_Version_Question__c WHERE Id = :stvq.Id];
        Base311_Attribute ra = new Base311_Attribute(stvq.Question__r.Flex_Question_Code__c, 'BLK101', stvq); 
        String val = ra.stringifyValue();
        System.assertEquals('BLK101', val);
    }
    
    @isTest
    static void testStringifySingleFail() {
        try{ 
           
            Question__c q = Test_RestTestHelper.question('', 'MultiPicklist', '');
            Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
            Service_Type_Version_Question__c stvq = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv.Id);
            stvq.Override_Answer_Values__c = '[{"key":"BLK101", "value":"BLK101"}]';
            update stvq;
        stvq = [SELECT Name,  Question__r.Question__c, Question__r.Data_Type__c, Override_Answer_Values__c, Question__r.Flex_Question_Code__c  FROM Service_Type_Version_Question__c WHERE Id = :stvq.Id];
        Base311_Attribute ra = new Base311_Attribute(stvq.Question__r.Flex_Question_Code__c, 'bad', stvq);
            ra.stringifyValue();
        } catch(Base311_Exceptions.UnsupportedException e) {
            System.assert(true);
            return;
        }
            System.assert(false);
    }
}