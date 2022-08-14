// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

interface IMarket {
    function list(
        uint256,
        uint256,
        uint256,
        address
    ) external;

    function unlist(uint256) external;
    function purchase(uint256) external payable;

    event Listed(uint256 indexed itemId, address author, uint256 price);
    event UnListed(uint256 indexed itemId, address author);
    event ItemPurchased(uint256 indexed itemId, address prevOwner, address newOwner);
}
