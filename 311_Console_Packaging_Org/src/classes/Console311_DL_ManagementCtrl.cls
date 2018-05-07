global class Console311_DL_ManagementCtrl {

     public static List<Incap311__Service_Queue__c> fetchAllDistributionLists() {
            return null;
     }


      //Method to fetch Distribution lists and Serialize Wrapper Object as JSON
        public static String getDistributionLists() {
            List <DistributionListwrap> disWrapList = new List <DistributionListwrap> ();
            List <Incap311__Service_Queue__c> disList = fetchAllDistributionLists();

            for (Incap311__Service_Queue__c dl: disList) {
                DistributionListwrap dlwrap = new DistributionListwrap();
                dlwrap.id = dl.id;
                dlwrap.name = dl.name;
                if (dl.Incap311__Queue_Code__c != null) {
                    dlwrap.code = dl.Incap311__Queue_Code__c;
                }
                if (dl.Incap311__Is_System_Default__c != null) {
                    dlwrap.isDefault = dl.Incap311__Is_System_Default__c;
                }
                if (dl.Incap311__Queue_Code__c != null) {
                    dlwrap.code = dl.Incap311__Queue_Code__c;
                }
                disWrapList.add(dlwrap);
            }
            return JSON.serialize(disWrapList);
         }

     
     private void upsertDistributionList(Incap311__Service_Queue__c servicedl) {      
        try {
            upsert servicedl;
        } catch(System.Exception ex){
           System.debug('Create New Distribution List Error -->' + ex.getMessage());
        }
    }
    

    
    //Subclass : Wrapper Class 
    public class Accountwrap {
        //Static Variables 
        public string id;
        public string name;
        public string Phone;
        public string Fax;
        public string Website;
        
        //Wrapper  Class Controller
        Accountwrap() {
            Phone = '';
            Fax = '';
            Website = '';
        }
        
    }

    //Subclass : Wrapper Class 
    public class DistributionListwrap {
        //Static Variables 
        public string id;
        public string name;
        public string code;
        public Boolean isDefault;
        public List<Memberwrap> members;
        
        //Wrapper  Class Controller
        DistributionListwrap() {
            code = '';
            isDefault = false;
        }
        
    }

    //Subclass : Wrapper Class 
    public class Memberwrap {
        //Static Variables 
        public string id;
        public string name;
        public Contactwrap contact;
        public Boolean isCoordinator;      
        //Wrapper  Class Controller
        Memberwrap() {
            isCoordinator = false;
        }
        
    }

    //Subclass : Wrapper Class 
    public class Contactwrap {
        //Static Variables 
        public string id;
        public string lastname;
        public string firstname;
        public String email;
        
        //Wrapper  Class Controller
        Contactwrap() {
            lastname = 'dlmember';
        }
        
    }
       
    //Method to bring the list of Account and Serialize Wrapper Object as JSON
    public  static String getlstAccount() {
        List < Accountwrap > lstwrap = new List < Accountwrap > ();
        List < account > lstacc = [SELECT Id, Name, Phone,Fax,Website
                                   FROM Account order by name limit 50
                                  ];
        for (Account a: lstacc) {
            Accountwrap awrap = new Accountwrap();
            awrap.id = a.id;
            awrap.name = a.name;
            if (a.Phone != null) {
                awrap.Phone = a.Phone;
            }
            if (a.Fax != null) {
                awrap.Fax = a.Fax;
            }
            if (a.Website != null) {
                awrap.Website = a.Website;
            }
            lstwrap.add(awrap);
        }
        return JSON.serialize(lstwrap);
     }

    @RemoteAction
    global static string createAccount(string name,string phone,string fax,string website){
        String fax1 = fax == 'null' ? NULL : fax;
        String website1 = website == 'null' ? NULL : website;
        Account acc = new Account(name=name,phone=phone,fax=fax1,website=website1);
        insert acc;
        return acc.id;
    }
    @RemoteAction
    global static void updateAccount(string id,string name,string phone,string fax,string website){
        String fax1 = fax == 'null' ? NULL : fax;
        String website1 = website == 'null' ? NULL : website;
        Account acc = new Account(name=name,phone=phone,id=id,fax=fax1,website=website1);
        update acc;
    }
    @RemoteAction
    global static void deleteAccount(string id){
        Account acc = [select id from account where id =: id];
        delete acc;
    }
}