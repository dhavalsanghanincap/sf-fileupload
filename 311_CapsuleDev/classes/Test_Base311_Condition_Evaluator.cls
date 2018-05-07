@isTest
public class Test_Base311_Condition_Evaluator {
    @isTest
    static void testConditionGroupOrFalse() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
        Base311_Dependency dep = new Base311_Dependency();
        dep.clause = 'OR';
        dep.conditions = new List<Base311_Dependency>{ 
        	new Base311_Dependency(2, 1, 'eq'),
        	new Base311_Dependency(0, 1, 'gt')
        };
            
        System.assertEquals(ce.conditionGroup(dep), false);
    }

    @isTest
    static void testConditionGroupOr() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
        Base311_Dependency dep = new Base311_Dependency();
        dep.clause = 'OR';
        dep.conditions = new List<Base311_Dependency>{ 
        	new Base311_Dependency(1, 1, 'eq'),
        	new Base311_Dependency(0, 1, 'gt')
        };
            
        System.assertEquals(ce.conditionGroup(dep), true);
    }

    @isTest
    static void testConditionGroupAndFalse() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
        Base311_Dependency dep = new Base311_Dependency();
        dep.clause = 'AND';
        dep.conditions = new List<Base311_Dependency>{ 
        	new Base311_Dependency(1, 1, 'eq'),
        	new Base311_Dependency(0, 1, 'gt')
        };
            
        
        System.assertEquals(ce.conditionGroup(dep), false);
    }
    
    @isTest
    static void testConditionGroupAnd() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
        Base311_Dependency dep = new Base311_Dependency();
        dep.clause = 'AND';
        dep.conditions = new List<Base311_Dependency>{ 
        	new Base311_Dependency(1, 1, 'eq'),
        	new Base311_Dependency(2, 1, 'gt')
        };
            
        
        System.assertEquals(ce.conditionGroup(dep), true);
    }
    @isTest
    static void testConditionInFalse() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
        Base311_Dependency dep = new Base311_Dependency();
        dep.left = '1';
        dep.right = new List<String>{ '2' };
        dep.op = 'in';
        
        System.assertEquals(ce.condition(dep), false);
    }
    
    @isTest
    static void testConditionIn() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
        Base311_Dependency dep = new Base311_Dependency();
        dep.left = '1';
        dep.right = new List<String>{ '1' };
        dep.op = 'in';
        
        System.assertEquals(ce.condition(dep), true);
    }
    
    @isTest
    static void testConditionNEQFalse() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
        Base311_Dependency dep = new Base311_Dependency();
        dep.left = 3;
        dep.right = 3;
        dep.op = 'neq';
        
        System.assertEquals(ce.condition(dep), false);
    }
    
    @isTest
    static void testConditionNEQ() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
        Base311_Dependency dep = new Base311_Dependency();
        dep.left = 4;
        dep.right = 3;
        dep.op = 'neq';
        
        System.assertEquals(ce.condition(dep), true);
    }
    
    @isTest
    static void testConditionLteFalse() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
        Base311_Dependency dep = new Base311_Dependency();
        dep.left = 4;
        dep.right = 3;
        dep.op = 'lte';
        
        System.assertEquals(ce.condition(dep), false);
    }
    
    @isTest
    static void testConditionLteLess() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
        Base311_Dependency dep = new Base311_Dependency();
        dep.left = 2;
        dep.right = 3;
        dep.op = 'lte';
        
        System.assertEquals(ce.condition(dep), true);
    }

    @isTest
    static void testConditionLteEqual() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
        Base311_Dependency dep = new Base311_Dependency();
        dep.left = 2;
        dep.right = 2;
        dep.op = 'lte';
        
        System.assertEquals(ce.condition(dep), true);
    }

    
    @isTest
    static void testConditionGteFalse() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
        Base311_Dependency dep = new Base311_Dependency();
        dep.left = 2;
        dep.right = 3;
        dep.op = 'gte';
        
        System.assertEquals(ce.condition(dep), false);
    }
    
    
    @isTest
    static void testConditionGteGreater() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
        Base311_Dependency dep = new Base311_Dependency();
        dep.left = 4;
        dep.right = 3;
        dep.op = 'gte';
        
        System.assertEquals(ce.condition(dep), true);
    }
    
    @isTest
    static void testConditionGteEqual() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
        Base311_Dependency dep = new Base311_Dependency();
        dep.left = 2;
        dep.right = 2;
        dep.op = 'gte';
        
        System.assertEquals(ce.condition(dep), true);
    }
    
    @isTest
    static void testConditionGtFalse() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
        Base311_Dependency dep = new Base311_Dependency();
        dep.left = 3;
        dep.right = 3;
        dep.op = 'gt';
        
        System.assertEquals(ce.condition(dep), false);
    }
    
    @isTest
    static void testConditionGt() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
        Base311_Dependency dep = new Base311_Dependency();
        dep.left = 3;
        dep.right = 2;
        dep.op = 'gt';
        
        System.assertEquals(ce.condition(dep), true);
    }
    
    @isTest
    static void testConditionLtFalse() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
        Base311_Dependency dep = new Base311_Dependency();
        dep.left = 2;
        dep.right = 2;
        dep.op = 'lt';
        
        System.assertEquals(ce.condition(dep), false);
    }
   
    @isTest
    static void testConditionLt() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
        Base311_Dependency dep = new Base311_Dependency();
        dep.left = 1;
        dep.right = 2;
        dep.op = 'lt';
        
        System.assertEquals(ce.condition(dep), true);
    }
     
    @isTest
    static void testConditionEqFalse() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
        Base311_Dependency dep = new Base311_Dependency();
        dep.left = '1';
        dep.right = '2';
        dep.op = 'eq';
        
        System.assertEquals(ce.condition(dep), false);
    }
    
    @isTest
    static void testConditionEq() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
        Base311_Dependency dep = new Base311_Dependency();
        dep.left = '1';
        dep.right = '1';
        dep.op = 'eq';
        
        System.assertEquals(ce.condition(dep), true);
    }
    
    @isTest
    static void testContainsListListFalse() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
        System.assertEquals(ce.contains(new List<String>{ 'b', 'e' }, new List<String>{ 'a', 'b', 'c', 'd' }), false);
    }
    
    @isTest
    static void testContainsListList() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
        System.assertEquals(ce.contains(new List<String>{ 'b', 'd' }, new List<String>{ 'a', 'b', 'c', 'd' }), true);
    }
    
    @isTest
    static void testContainsListFalse() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
        System.assertEquals(ce.contains('c', new List<String>{ 'b', 'a' }), false);
    }
    
    @isTest
    static void testContainsList() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
        System.assertEquals(ce.contains('a', new List<String>{ 'b', 'a' }), true);
    }
    
    @isTest
    static void testContainsStringFalse() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
        System.assertEquals(ce.contains('bb', 'accab'), false);
    }
    
    @isTest
    static void testContainsString() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
        System.assertEquals(ce.contains('ab', 'accab'), true);
    }
    
    @isTest
    static void testEqualListFalse() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
        System.assertEquals(ce.equal(new List<String>{ '4', '2', '3' }, new List<String>{ '1', '2', '3'}), false);
    }
    
    @isTest
    static void testEqualList() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
        System.assertEquals(ce.equal(new List<Integer>{ 1, 2, 3 }, new List<String>{ '1', '2', '3'}), true);
    }
    
    @isTest
    static void testEqualIntegerFalse() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
		System.assertEquals(ce.equal(1, 2), false);
    }
    
    @isTest
    static void testEqualInteger() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
		System.assertEquals(ce.equal(1, 1), true);
    }
    
    @isTest
    static void testEqualStringMixed() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
		System.assertEquals(ce.equal(1, '1'), true);
    }
    
    @isTest
    static void testEqualStringFalse() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
		System.assertEquals(ce.equal('abc', 'cbc'), false);
    }
    
    @isTest
    static void testEqualString() {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator();
		System.assertEquals(ce.equal('abc', 'abc'), true);
    }
    
    @isTest
    static void testSideSimple() {
        Map<String, Object> items = new Map<String, Object>();         
        items.put('ABC', 'apple');
        
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator(items);
        
        System.assertEquals(ce.side('banana'), 'banana');
    }
    
    @isTest
    static void testSideStatement() {
        Map<String, Object> items = new Map<String, Object>();         
        items.put('ABC', 'apple');
        
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator(items);
        
        System.assertEquals(ce.side('ServiceQuestionCode[ABC].Incap311__Answer__c'), 'apple');
    }
    
    @isTest
    static void testIsStatement() {
        System.assertEquals(Base311_Condition_Evaluator.isStatement('ServiceQuestionCode[ABC].Incap311__Answer__c'), true);
    }

    @isTest
    static void testIsStatementFalse() {
        System.assertEquals(Base311_Condition_Evaluator.isStatement('asdasd[DEF].Incap311__Answer__c'), false);
    }

    @isTest
    static void testStatement() {
        Map<String, Object> items = new Map<String, Object>();         
        items.put('ABC', 'apple');
        
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator(items);
        
        System.assertEquals(ce.statement('ServiceQuestionCode[ABC].Incap311__Answer__c'), 'apple');
    }

    @isTest
    static void testStatementDNE() {
        Map<String, Object> items = new Map<String, Object>();         
        items.put('ABC', 'apple');
        
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator(items);
        
        System.assertEquals(ce.statement('ServiceQuestionCode[DEF].Incap311__Answer__c'), null);
    }
}