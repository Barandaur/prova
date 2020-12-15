pragma solidity 0.7.5;
//"SPDX-License-Identifier: UNLICENSED"

// Deploy votingEcosystem, then only LetterCredit, passing the former contract's address
// NOTE: need to set an higher gas limit 

// need to click on the error on the left, and remove 'internal' from the constructor
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";
import "https://github.com/Barandaur/prova/blob/main/events.sol";

contract votingEcosystem is Ownable, Events {
    
        struct Voter {
        // whether this voter voted on a specific contract (specified by address)
        mapping(address => bool) voted;  // if true, that person already voted
        mapping(address => uint) vote;   // index of the voted proposal 
        }
        
        // maps each bank to its struct
        mapping(address => Voter) voters;
        mapping(address => bool)  public allowed_to_vote;
    
        function giveRightToVote(address voter) public onlyOwner {
            require(allowed_to_vote[voter] == false , "The user is already allowed to vote");
            // below check isn't required nor useful as of now
            //require(!voters[voter].voted,"The voter has already voted");
        
            allowed_to_vote[voter] = true;
            emit NewVoter(voter); }
    
        function removeRightToVote(address voter) public onlyOwner {
            require(allowed_to_vote[voter] != false , "The user is already not allowed to vote");
            
            allowed_to_vote[voter] = false;
            emit RemovedVoter(voter);    }
            
        function cast_vote(uint _vote, address payable contract_address) public {
            
            // need this require in both contracts
            bool isbank = allowed_to_vote[msg.sender];
            require(isbank == true, "must be allowed to vote");
        
            // access the Voter struct for a specific bank
            Voter storage sender = voters[msg.sender]; 
            
            // modify varaibles before calling the other contract
            sender.voted[contract_address] = true;
            sender.vote[contract_address] = _vote;
            
            // other requires are in the letter of credit contract
            LetterCredit contr = LetterCredit(contract_address);
            contr.vote(_vote);
        }
        
        function isvoter(address _address) public view returns(bool _b) {
            return allowed_to_vote[_address];
        }
        
        function has_voted(address contr_addr, address voter_addr) public view returns(bool _b) {
            return voters[contr_addr].voted[voter_addr];
        }
         
        function what_has_voted(address contr_addr, address voter_addr) public view returns(uint _b) {
            return voters[contr_addr].vote[voter_addr];
        }
}


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
    
    // keep track of who voted
    address[] voter_addresses;

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
    address[] winning_address;
    
}


contract Ballot is Ownable, Events, Variables {
    
    using SafeMath for uint;
    
    constructor(address _vot_ecosystem) {
        vot_ecosystem = _vot_ecosystem;
    }
    
    
    function VotingEndTime(uint v_number_of_days) external onlyOwner {
        v_deadline = _UploadTime.add(v_number_of_days * 1 days);
        v_time = voting_time.ON_TIME;
    }
    
    /* let a bank vote, modifying its Voter struct accordingly */
    function vote(uint proposal) public {
        
        // checks on this contract
        require(status == contract_status.SELLER_UPLOADED, "Can't vote on a document not yet uploaded");
        if (block.timestamp >= v_deadline) {
	        v_time = voting_time.OUT_OF_TIME;
	    }
	    require(v_time == voting_time.ON_TIME, "Invalid status, status is not ON_TIME");
	    
	    // checks on the voting ecosystem contract
        bool isbank = votingEcosystem(vot_ecosystem).isvoter(msg.sender);
        require(isbank == true, "must be allowed to vote");
        bool voted = votingEcosystem(vot_ecosystem).has_voted(address(this), msg.sender);
        require(voted == false, "Already voted.");
        
        // store the fact that this address voted. Will be used
        // to make him eligible for the reward fee
        voter_addresses.push(msg.sender);
        
        // use his vote to increase the appropriate counter
        if (proposal == 0){
            no_compliance_votes +=1;}
        else {
            if (proposal ==1){
                compliance_votes +=1;}
        }
    }


    function winningProposal() internal view returns (uint winningProposal_){
        if (no_compliance_votes>=compliance_votes){
            winningProposal_ = 0;
        }
        else {
            winningProposal_ = 1;
        }
    }
        
    function voteAccordingMajority() internal  {

        for (uint p = 0; p < voter_addresses.length; p++) {
            
            address voter_address = voter_addresses[p];

            if (votingEcosystem(vot_ecosystem).what_has_voted(address(this), msg.sender) == winningProposal()) {
                winning_address.push(voter_address);
            }
        }
    }
    
}
