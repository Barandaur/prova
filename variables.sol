/*
* @dev put variables here to ease the reading. Is this safe?
*/
contract Variables {
    
    // -----------------------------------------  Ballot Variables  ----------------------------------------- //
    
    // keep track of the contract status
    enum contract_status  {ON, BUYER_UPLOADED, SELLER_UPLOADED, 
                            DOC_OK, DOC_DEFECT,DOC_REJECTED, 
                            MONEY_SENT} contract_status status;
    
    // keep track of the voting deadline
    enum voting_time {ON_TIME, OUT_OF_TIME} voting_time v_time;
    

    // keep track of the number of accumulated votes for each proposal
    uint no_compliance_votes = 0;
    uint compliance_votes = 0;
    

    // voting deadline: set by the fintech (days), and starts when the seller 
    // uploads the documents.
    uint public v_deadline;
    
    // records when the seller uploads the documents
    uint _UploadTime;
    
    
    struct Voter {
    bool voted;
    uint vote;
    }
    mapping(address => Voter) voters;
    
    // keep track of who voted
    address[] public voter_addresses;
    address[] public winning_address;

    // -----------------------------------------  LetterCredit Variables  ----------------------------------------- //
    
    
    // define the addresses of the parties involved
    address payable public buyer;
    address payable public seller;
    address payable public fintech;
    
    address public vot_ecosystem;
    
    // checks whether the seller is on time to upload the documents
    enum contract_time {ON_TIME, OUT_OF_TIME} contract_time time;
    
    // define deadline, and extension (set by the buyer)
    uint public deadline;
    uint extension;
    
    // in case the buyer wants to waive discrepancies, it is set to true
    bool waive; 

    // records the balance for each player
    mapping(address => uint) balance;
    
    // records the document hash for each player (bytes32 in production?)
    mapping(address => string) docu_hashs;
    

    // define fees held by the fintech company in case of compliance,
    // and of no compliance
    uint defect_fee; 
    uint compliance_fee; 
}