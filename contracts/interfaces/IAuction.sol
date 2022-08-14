// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

interface IAuction {
    function start(uint) external;
    function bid() external payable;
    function withdraw() external;
    function end() external;
    function whitelist(address) external;
    function unWhitelist(address) external;

    event Whitelisted(address indexed user);
    event UnWhitelisted(address indexed user);

    event StartAuction(address indexed seller, uint itemId);
    event Bid(address indexed bidder, uint amount, uint itemId);
    event Withdraw(address indexed bidder, uint amount);
    event End(address winner, uint amount);
}
