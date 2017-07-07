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

contract Crowdsale {
    address public recipient;
    uint public targetAmount;
    uint public raisedAmount;
    uint public deadline;
    uint public price;
    Token public tokenReward;
    struct Funder {
        address addr;
        uint amount;
    }
    Funder[] public funders;
    function Crowdsale(address _recipient, uint _targetAmount, uint _duration, uint _price, Token _reward) payable {
        recipient = _recipient;
        targetAmount = _targetAmount;
        deadline = now + _duration * 1 minutes;
        price = _price;
        tokenReward = Token(_reward);
    }
    function () payable {
        uint amount = msg.value;
        funders[funders.length++] = Funder({addr: msg.sender, amount: amount});
        raisedAmount += amount;
        tokenReward.transfer(msg.sender, amount / price);
    }

    modifier afterDeadline() {
        if (now >= deadline) _;
    }

    function checkTargetAchieved() afterDeadline {
        if (raisedAmount >= targetAmount) {
            recipient.send(raisedAmount);
        } else {
            for (uint i = 0; i < funders.length; ++i){
                funders[i].addr.send(funders[i].amount);
            }
        }
        suicide(recipient);
    }
}
