// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
 
 // https://ethereum.org/en/developers/docs/standards/tokens/erc-20/
 // https://eips.ethereum.org/EIPS/eip-20

contract OtusERC20 {
    mapping(address account => uint256) private _amounts;
    mapping(address account => mapping(address spender => uint256)) private _allowances;
    uint256 private _total;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(uint256 total) {
        _total = total;
        _amounts[msg.sender] = total;
    }
    function name() public pure returns (string memory) {
        return "Otus ERC-20";
    }
    function symbol() public pure returns (string memory) {
        return "OTUSERC20";
    }
    function decimals() public pure returns (uint8) {
        return 18;
    }
    function totalSupply() public view returns (uint256) {
        return _total;
    }
    function balanceOf(address account) public view returns (uint256) {
        return _amounts[account];
    }
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    function transfer(address to, uint256 value) public returns (bool) {
        address from = msg.sender;

        require(_amounts[from] >= value, "Insufficient balance");

        _amounts[from] -= value;
        _amounts[to] += value;

        emit Transfer(from, to, value);
        return true;
    }
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        address spender = msg.sender;

        require(_allowances[from][spender] >= value, "Insufficient allowance");
        require(_amounts[from] >= value, "Insufficient balance");

        _allowances[from][spender] -= _allowances[from][spender] == type(uint256).max ? 0 : value; 
        _amounts[from] -= value;
        _amounts[to] += value;            

        emit Transfer(from, to, value);
        return true;
    }
    function approve(address spender, uint256 value) public returns (bool) {
        address owner = msg.sender;

        _allowances[owner][spender] = value;

        emit Approval(owner, spender, value);
        return true;
    }
}
