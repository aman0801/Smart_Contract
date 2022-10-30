//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0<0.9.0;

contract voting
{
    address contractOwner;
    address[] public CandidatedList;
     
    mapping(address => uint) public VotesReceived;

    address public winner;
    uint public winnerVotes;

    enum votingStatus { NotStarted, Running, completed }
    votingStatus public status;

    constructor() 
    {
        contractOwner = msg.sender;
    } 

    modifier OnlyOwner
    {
        require(msg.sender == contractOwner, "Only owner");
         _;
    }

    function setStatus() OnlyOwner public
    {
        if(status!=votingStatus.completed)
        {
            status = votingStatus.Running;
        }else
        {
            status = votingStatus.completed;
        }
    }

    function RegisteredCandidates(address _candidates) OnlyOwner public 
    {
        CandidatedList.push(_candidates);
    }

    function vote(address _candidates) public
    {
        require(validateCandidate(_candidates), "Not valid candidate");
        require(status == votingStatus.Running, "election not active");
        VotesReceived[_candidates] = VotesReceived[_candidates] + 1;
    }

    function validateCandidate(address _candidates) view public returns(bool)
    {
        for(uint i=0; i<CandidatedList.length; i++){
            if(CandidatedList[i] == _candidates)
            {
                return true;
            }
        }
        return false;
    }

    function votesCount(address _candidates)public view returns(uint)
    {
        require(validateCandidate(_candidates), "Not valid candidate");
        assert(status == votingStatus.Running);
        return VotesReceived[_candidates];
    }

    function result()public 
    {
        require(status == votingStatus.Running, "election not active");
        for(uint i=0; i<CandidatedList.length; i++)
        {
            if(VotesReceived[CandidatedList[i]] > winnerVotes)
            {
                winnerVotes = VotesReceived[CandidatedList[i]];
                winner = CandidatedList[i];
            }
        }
    }



}