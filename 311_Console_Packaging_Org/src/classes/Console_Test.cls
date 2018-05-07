public class Console_Test {

    public Console_Test(ApexPages.StandardController controller) {
    
    }

    public Boolean flag { get; set; }

    public void setFlag() {
        if(this.flag == null) {
            this.flag = false;
        }
    
        this.flag = !this.flag;
    }

}