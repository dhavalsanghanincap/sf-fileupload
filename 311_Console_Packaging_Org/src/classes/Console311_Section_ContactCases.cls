public class Console311_Section_ContactCases {

    private Incap311.Base311_Service_Request bsr = new Incap311.Base311_Service_Request();

    public Id cId { get; set; }

    public List<Case> getContactCases() {
        return bsr.getContactRequests(cId);
    }

}