//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0<0.9.0;

contract CrowdFunding
{
    mapping(address=>uint) public contributors;
    address public manager;
    uint public MinimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;

    struct request
    {
        string description;
        address payable recepient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool) Voters;
    }
     mapping(uint=>request) public requests;
    uint numRequests;

    constructor(uint _target,uint _deadline)
    {
        target=_target;
        deadline=block.timestamp+_deadline;
        MinimumContribution=100 wei;
        manager=msg.sender;
    }

    function sendETH() public payable
    {
        require(block.timestamp<deadline,"Deadline Passed");
        require(msg.value>=MinimumContribution,"More Please");
        
        if(contributors[msg.sender]==0){
            noOfContributors++;
        }
         contributors[msg.sender]+=msg.value;
        raisedAmount+=msg.value;
    }
    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }

    function refund() public
    {
        require(block.timestamp>deadline && raisedAmount<target,"Not Egligible");
        require(contributors[msg.sender]>0);
        address payable user=payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
    }

    modifier onlyManager()
    {
        require(msg.sender==manager,"Only Manager");
        _;
    }
    function createRequests(string memory _description,address payable _recepient,uint _value) public onlyManager
    {
        request storage newRequest= requests[numRequests];
        numRequests++;
        newRequest.description=_description;
        newRequest.recepient=_recepient;
        newRequest.value=_value;
        newRequest.completed=false;
        newRequest.noOfVoters=0;
    }

    function VoteRequest(uint _requestNo) public
    {
        require(contributors[msg.sender]>0,"Must be contributor");
        request storage thisRequest=requests[_requestNo];
        require(thisRequest.Voters[msg.sender]==false,"Voted");
        thisRequest.Voters[msg.sender]=true;
        thisRequest.noOfVoters++;
    }
      function makePayment(uint _requestNo) public onlyManager
      {
        require(raisedAmount>=target);
        request storage thisRequest=requests[_requestNo];
        require(thisRequest.completed==false,"The request has been completed");
        require(thisRequest.noOfVoters > noOfContributors/2,"Majority does not support");
        thisRequest.recepient.transfer(thisRequest.value);
        thisRequest.completed=true;
    }

}