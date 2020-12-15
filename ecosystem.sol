pragma solidity 0.7.5;
//"SPDX-License-Identifier: UNLICENSED"

// Deploy votingEcosystem, then only LetterCredit, passing the former contract's address
// NOTE: need to set an higher gas limit 

// need to click on the error on the left, and remove 'internal' from the constructor
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";
import "https://github.com/Barandaur/prova/blob/main/events.sol";
import "https://github.com/Barandaur/prova/blob/main/LetterCredit.sol";

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
