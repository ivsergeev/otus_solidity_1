// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// https://ethereum.org/en/developers/docs/standards/tokens/erc-721/
// https://eips.ethereum.org/EIPS/eip-721


interface ERC721{
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) external payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

interface ERC721Metadata{
    function name() external view returns (string memory _name);
    function symbol() external view returns (string memory _symbol);
    function tokenURI(uint256 _tokenId) external view returns (string memory);
}

interface ERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

interface ERC721TokenReceiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory _data) external returns(bytes4);
}

contract OtusERC721 is ERC165, ERC721, ERC721Metadata{
    address private _owner;
    mapping(uint256 tokenId => address) private _owners;
    mapping(address owner => uint256) private _balances;
    mapping(uint256 tokenId => address) private _tokenApprovals;
    mapping(address owner => mapping(address operator => bool)) private _operatorApprovals;

    constructor() {
        _owner = msg.sender;
    }

    // ERC-165
    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return
            interfaceId == type(ERC721).interfaceId ||
            interfaceId == type(ERC721Metadata).interfaceId ||
            interfaceId == type(ERC165).interfaceId;
    }

    // ERC-721 Metadata
    function name() public pure returns (string memory) {
        return "Otus ERC-721";
    }
    function symbol() public pure returns (string memory) {
        return "OTUSERC20";
    }
    function tokenURI(uint256 tokenId) public pure returns (string memory) {
        return "";
    }

    // ERC-721
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "Invalid owner address");
        return _balances[owner];
    }
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Invalid tokenId");
        return owner;
    }
    function safeTransferFrom(address from, address to, uint256 tokenId) public payable{
        safeTransferFrom(from, to, tokenId, "");
    }
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public payable{
        transferFrom(from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, data);
    }
    function transferFrom(address from, address to, uint256 tokenId) public payable {
        require(from != address(0), "Invalid from address");
        require(to != address(0), "Invalid to address");

        address owner = _owners[tokenId];
        
        require(owner == from || _operatorApprovals[owner][from] || _tokenApprovals[tokenId] == from, "Invalid operation");

        delete _tokenApprovals[tokenId];

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }
    function approve(address to, uint256 tokenId) public payable{
        address owner = _owners[tokenId];
        require(msg.sender == owner || _operatorApprovals[owner][msg.sender], "Invalid operation"); 
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }
    function setApprovalForAll(address operator, bool approved) public {
        require(operator != address(0), "Invalid operator address");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }
    function getApproved(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Invalid tokenId");
        return _tokenApprovals[tokenId];
    }
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    // mint-burn
    function mint(address to, uint256 tokenId) public {
        require(msg.sender == _owner, "Invalid operation");
        require(to != address(0), "Invalid to address");

        address owner = _owners[tokenId];
        require(owner == address(0), "Token already exists");

        _owners[tokenId] = to;
        _balances[to] += 1;

        emit Transfer(address(0), to, tokenId);
    }
    function burn(uint256 tokenId) public {
        address owner = _owners[tokenId];
        require(owner != address(0), "Invalid tokenId");
        require(owner == msg.sender || _operatorApprovals[owner][msg.sender] || _tokenApprovals[tokenId] == msg.sender, "Invalid operation");

        delete _owners[tokenId];
        delete _tokenApprovals[tokenId];

        _balances[owner] -= 1;

        emit Transfer(owner, address(0), tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private {
        if (to.code.length > 0) {
            try ERC721TokenReceiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                require(retval == ERC721TokenReceiver.onERC721Received.selector, "Invalid receiver");
            } catch (bytes memory reason) {
                require(reason.length != 0, "Invalid receiver");
                assembly {
                    revert(add(32, reason), mload(reason))
                }
            }
        }
    }
}