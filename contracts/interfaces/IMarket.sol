// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

interface IMarket {
    function list(uint, uint, uint, address) external;
    function unlist(uint) external;
    function purchase(uint) external payable;

    event Listed(uint indexed itemId, address author, uint price);
    event UnListed(uint indexed itemId, address author);
    event ItemPurchased(uint indexed itemId, address prevOwner, address newOwner);
}
