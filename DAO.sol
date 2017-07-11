pragma solidity ^0.4.0;
contract Token {
    mapping (address => uint) public balanceOf;
    uint public count;

    function Token(uint initialSupply) {
        balanceOf[msg.sender] = initialSupply;
    }
    function transfer(address _to, uint _value) returns(bool) {
        if(balanceOf[msg.sender] < _value) return false;
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        return true;
    }
    function () payable {
        count += 1;
    }
}

contract DAO {
    uint public minimumAttendance;
    uint public discussionPeriod;
    Token public tokenAddress;
    address public founder;
    Plan[] public plans;
    uint public numPlans;
    struct Plan {
        address recipient;
        uint amount;
        bytes32 data;
        string detail;
        uint createdAt;
        bool active;
        Vote[] votes;
        mapping (address => bool) voted;
    }
    struct Vote {
        int position;
        address voter;
    }
    function DAO(Token _tokenAddress, uint _minimumAttendance, uint _discussionPeriod) payable {
        founder = msg.sender;
        tokenAddress = Token(_tokenAddress);
        minimumAttendance = _minimumAttendance;
        discussionPeriod = _discussionPeriod * 1 minutes;
    }
    function newPlan(address _recipient, uint _amount, bytes32 _data, string _detail) payable returns (uint planID) {
        if (tokenAddress.balanceOf(msg.sender) > 0) {
            planID = plans.length++;
            Plan p = plans[planID];
            p.recipient = _recipient;
            p.amount = _amount;
            p.data = _data;
            p.detail = _detail;
            p.createdAt = now;
            p.active = true;
            numPlans = planID + 1;
        }
    }
    function vote(uint _planID, int _position) payable returns(uint voteID) {
        if ((tokenAddress.balanceOf(msg.sender) > 0 ) && (_position >= -1 || _position <= 1 )) {
            Plan p = plans[_planID];
            if (p.voted[msg.sender] == true) return;
            voteID = p.votes.length++;
            p.votes[voteID] = Vote({position: _position, voter: msg.sender});
            p.voted[msg.sender] = true;
        }
    }
    function executePlan(uint _planID) returns (int result) {
        Plan p = plans[_planID];
        if (now > (p.createdAt + discussionPeriod) && p.active) {
            uint attendance = 0;
            for (uint i = 0; i < p.votes.length; ++i) {
                Vote v = p.votes[i];
                uint voteWeight = tokenAddress.balanceOf(v.voter);
                attendance += voteWeight;
                result += int(voteWeight) * v.position;
            }
            if (attendance > minimumAttendance && result > 0) {
                p.recipient.send(p.amount);
                p.active = false;
            } else if (attendance > minimumAttendance && result < 0) {
                p.active = false;
            }
        }
    }
    function () payable {
        
    }
}
