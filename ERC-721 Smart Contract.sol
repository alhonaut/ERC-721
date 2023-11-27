// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FICEToken is ERC721, ERC721Enumerable, ERC721Pausable, Ownable {
    uint256 private _nextTokenId;
    uint16 public max_supply = 10000; // 'max_supply' is number of all possible nft that can be created

    bool public publicMintOpen = false; // it's checker if public mint is open or closed
    bool public allowListMintOpen = false; // it's checker if allowList mint is open or closed

    mapping(address => bool) private allowList; // we make it private because we don't want that anybody can know this list
    mapping(address => uint8) nftPerUser;

    constructor(address initialOwner)
        ERC721("FICEToken", "FCT")
        Ownable(initialOwner)
    {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://ipfs.io/ipfs/QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/3865";
    }

    function changePublicMint() external onlyOwner returns(string memory) { //'memory' means that string will be in temporary memory
        string memory result;
        if (!publicMintOpen) {
            publicMintOpen = true;
            result = "Public Mint is Open now.";
        }
        else {
            publicMintOpen = false;
            result = "Public Mint is Close now.";
        }
        return result;
    }

    function changeAllowListMint() external onlyOwner returns(string memory) { //'memory' means that string will be in temporary memory
        string memory result;
        if (!allowListMintOpen) {
            allowListMintOpen = true;
            result = "AllowList Mint is Open now.";
        }
        else {
            allowListMintOpen = false;
            result = "AllowList Mint is Close now.";
        }
        return result;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function setAllowList(address[] calldata privileged_users) external onlyOwner { // we put here array of allowed addresses
        for (uint16 i = 0; i < privileged_users.length; i++) {
            allowList[privileged_users[i]] = true;
        }
    }

    function allowListMint() public payable {
        require(allowListMintOpen, "AllowList Mint is Closed.");
        require(allowList[msg.sender], "You not allowed to mint this NFT."); // check if sender in allowList
        require(msg.value == 0.001 ether, "Not enough funds."); // here we put smaller price for 'elite' users
        internalMint(msg.sender);
    }

    function publicMint() public payable { // 'payable' means that function is cost money for user
        require(publicMintOpen, "Public Mint is Closed.");
        require(msg.value == 0.01 ether, "Not enough funds."); //msg.value is how many funds have user to do payment
        internalMint(msg.sender);
    }

    function internalMint(address user) internal {
        require(totalSupply() < max_supply, "You can't mint this NFT anymore."); 
        require(nftPerUser[user] < 1, "You have already a NFT.");
        uint256 tokenId = _nextTokenId++;
        nftPerUser[user]++; // we write that user now have 1 NFT
        _safeMint(user, tokenId);
    }

    function withdrawBalance(address _address) external onlyOwner {
        uint256 contract_balance = address(this).balance; // get balance of the contract
        payable(_address).transfer(contract_balance); // we transfer balance from smart contract to our address

    }

    // The following functions are overrides required by Solidity.

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
