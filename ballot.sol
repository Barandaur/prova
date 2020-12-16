pragma solidity 0.7.5;
//"SPDX-License-Identifier: UNLICENSED"


// need to click on the error on the left, and remove 'internal' from the constructor
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
//import "https://github.com/Barandaur/prova/blob/main/events.sol";
//import "https://github.com/Barandaur/prova/blob/main/variables.sol";

contract Ballot is Ownable, Events, Variables {
    
    using SafeMath for uint;
    
    constructor(address _vot_ecosystem) {
        vot_ecosystem = _vot_ecosystem;
    }
    
    
    function VotingEndTime(uint v_number_of_days) internal  {
        v_deadline = _UploadTime.add(v_number_of_days * 1 days);
        v_time = voting_time.ON_TIME;
    }
    
    /* let a bank vote, modifying its Voter struct accordingly */
    function vote(uint proposal) public {
        
        // checks regarding this contract
        require(status == contract_status.SELLER_UPLOADED, "Can't vote on a document not yet uploaded");
        if (block.timestamp >= v_deadline) {
	        v_time = voting_time.OUT_OF_TIME;
	    }
	    require(v_time == voting_time.ON_TIME, "Invalid status, status is not ON_TIME");
	    
	    // checks on the voting ecosystem contract.
	    // we need to check that the original caller is a bank,
	    // but we can't use tx.origin since it can be frauded
	    //assert(msg.sender == tx.origin);
        bool isbank = votingEcosystem(vot_ecosystem).isvoter(msg.sender);
        require(isbank == true, "must be allowed to vote");
        bool voted = voters[msg.sender].voted;
        require(voted == false, "Already voted.");
        
        // access the Voter struct for a specific bank
        
        // modify varaibles before calling the other contract
        voters[msg.sender].voted = true;
        voters[msg.sender].vote = proposal;
        
        // store the fact that this address voted. Will be used
        // to make him eligible for the reward fee
        voter_addresses.push(msg.sender);
        
        // use his vote to increase the appropriate counter
        if (proposal == 0){
            no_compliance_votes +=1;}
        else {
            if (proposal == 1){
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
        return winningProposal_;
    }
        
    function voteAccordingMajority() internal  {

        for (uint p = 0; p < voter_addresses.length; p++) {
            
            address voter_address = voter_addresses[p];

            if (voters[voter_address].vote == winningProposal()) {
                winning_address.push(voter_address);
            }
        }
    }
}
    
