// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IAuction.sol";

contract Auction is IAuction, Ownable {
    IERC721 public nft;
    uint256 public nftId;

    uint256 private endAt;
    uint256 private durationInDays;
    uint256 private highestBid;
    uint256 private commissionPercentage;

    bool public started;
    bool public ended;
    address public highestBidder;
    address payable private seller;
    address payable private admin;

    mapping(address => uint256) internal bids;
    mapping(address => bool) internal whitelisted;

    constructor(
        address _nft,
        uint256 _nftId,
        uint256 _startingBid,
        uint256 _commissionPercentage,
        address _seller
    ) {
        nft = IERC721(_nft);
        nftId = _nftId;
        seller = payable(_seller); //payable(msg.sender);
        highestBid = _startingBid;
        commissionPercentage = _commissionPercentage;
        admin = payable(msg.sender);
    }

    function start(uint256 _durationInDays) external onlyOwner {
        require(!started, "started");
        require(msg.sender == seller, "not seller");

        nft.transferFrom(msg.sender, address(this), nftId);
        started = true;
        endAt = block.timestamp + _durationInDays * 1 days;

        emit StartAuction(seller, nftId);
    }

    function bid() external payable {
        require(started, "not started");
        require(block.timestamp < endAt, "ended");
        require(msg.value > highestBid, "value < highest");

        if (highestBidder != address(0)) {
            bids[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;

        emit Bid(msg.sender, msg.value, nftId);
    }

    function withdraw() external {
        require(msg.sender != seller, "AE: unauthorized withdrawal");
        uint256 bal = bids[msg.sender];
        bids[msg.sender] = 0;

        admin.transfer(bal * commissionPercentage);
        payable(msg.sender).transfer(bal - (bal * commissionPercentage));

        emit Withdraw(msg.sender, bal);
    }

    function end() external onlyOwner {
        require(started, "not started");
        require(block.timestamp >= endAt, "not ended");
        require(!ended, "ended");

        ended = true;
        if (highestBidder != address(0)) {
            nft.safeTransferFrom(address(this), highestBidder, nftId);
            seller.transfer(highestBid);
        } else {
            nft.safeTransferFrom(address(this), seller, nftId);
        }

        emit End(highestBidder, highestBid);
    }

    function whitelist(address _user) external {
        require(whitelisted[_user], "MC: already whitelisted");
        whitelisted[_user] = true;
        emit Whitelisted(_user);
    }

    function unWhitelist(address _user) external {
        require(!whitelisted[_user], "MC: not whitelisted");
        delete(whitelisted[_user]);
        emit UnWhitelisted(_user);
    }
}
