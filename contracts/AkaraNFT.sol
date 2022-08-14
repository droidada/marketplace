// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

contract AkaraNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private tokenIds;
    address private owner;

    constructor(address _marketplace) ERC721("AkaraNFT", "AkNFT") {
        owner = _marketplace;
    }

    function createToken(string memory _tokenURI) public returns (uint) {
        tokenIds.increment();
        uint newItemId = tokenIds.current();

        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, _tokenURI);
        setApprovalForAll(owner, true);
        return newItemId;
    }
}
