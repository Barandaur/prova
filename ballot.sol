pragma solidity 0.7.5;
//"SPDX-License-Identifier: UNLICENSED"

// need to click on the error on the left, and remove 'internal' from the constructor
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";
import "https://github.com/Barandaur/prova/blob/main/events.sol";
import "https://github.com/Barandaur/prova/blob/main/variables.sol";

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
