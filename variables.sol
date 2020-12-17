/*
* @dev put variables here to ease the reading. Is this safe?
*/
contract Variables {
    
    // --------------  Ballot Variables  -------------- //
    
    // keep track of the contract status
    enum contract_status  {ON, BUYER_UPLOADED, SELLER_UPLOADED,
                           DOC_OK, DOC_DEFECT,DOC_REJECTED,
                           MONEY_SENT} contract_status status;
    
    
    struct Voter {
    // new: map from num_doc to whether or not voted on that doc
    mapping (uint => bool) voted;
    // new: map from num_doc to vote expressed
    mapping (uint=> uint) vote;
    }
    // map each bank to its Voter struct
    mapping(address => Voter) voters;
    
    // keep track of who voted, mapping with num_doc as key
    mapping (uint => address[])  voter_addresses;
    // keep track of who 'won' a voting, to give them the reward fee
    address[] winning_address;

    // --------------  LetterCredit Variables  -------------- //
    
    
    // define the addresses of the parties involved
    address payable public buyer;
    address payable public seller;
    // not set to public because there0's already an owner getter
    address payable fintech;
    
    // new: address of vot_ecosystem contract
    address public vot_ecosystem;
    
    // records the buyer's document hash (bytes32 in production?)
    string buyer_doc_hash;
    // new: num docs the seller will have to upload
    uint num_docs_to_upload;
    // new: keep track of num uploaded documents
    uint num_docs_uploaded;
    
    //new: map each seller's document to its hashes
    mapping (uint=> string) seller_documents;
    // new: map each doc to its compliance status
    mapping (uint=> bool) compliances;
    // new: keep track of the num of uncompliant documents
    uint uncompl_docs;
    
    // new: struct to track seller documents and votings on them
    struct Documents {
        uint voting_deadline;
        uint votes_for_compliance;
        uint votes_for_no_compliance;
    }
    // new: mapping for the above struct
    mapping (uint => Documents) document;
    // new: mapping to avoid checking compliance on not uploaded docs
    mapping (uint => bool) need_to_check_compl;
    
    // define deadline, and extension (set by the buyer)
    uint deadline;

    // records the balance for each player
    mapping(address => uint) balance;    

    // define fees held by the fintech company.. 
    uint public defect_fee;      // ..in case of compliance,
    uint public compliance_fee;  // ..in case of no compliance
}
