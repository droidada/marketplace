// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

interface IAuction {
    function start(uint256) external;

    function bid() external payable;

    function withdraw() external;

    function end() external;

    function whitelist(address) external;

    function unWhitelist(address) external;

    event Whitelisted(address indexed user);
    event UnWhitelisted(address indexed user);

    event StartAuction(address indexed seller, uint256 itemId);
    event Bid(address indexed bidder, uint256 amount, uint256 itemId);
    event Withdraw(address indexed bidder, uint256 amount);
    event End(address winner, uint256 amount);
}
