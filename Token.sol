contract Token {
    mapping (address => uint) public balanceOf;
    
    function Token(uint initialSupply) payable{
        balanceOf[msg.sender] = initialSupply;
    }
    function transfer(address _to, uint _value) returns(bool) {
        if(balanceOf[msg.sender] < _value) return false;
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        return true;
    }
}
