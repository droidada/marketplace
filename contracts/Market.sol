// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IMarket.sol";

contract Market is Ownable, IMarket {
    struct Item {
        bool listed;
        uint256 royalty;
        uint256 id;
        uint256 price;
        address author;
        address host;
        address owner;
    }

    address internal admin;
    uint256 internal comissionPercentage;
    mapping(uint256 => Item) internal items;
    mapping(address => bool) internal itemHosts;

    constructor(address _admin, uint256 _comissionPercentage) {
        admin = _admin;
        comissionPercentage = 100 / _comissionPercentage;
    }

    function list(
        uint256 _itemId,
        uint256 _price,
        uint256 _royalty,
        address _itemHost
    ) external {
        require(items[_itemId].listed, "MC: already listed");
        require(itemHosts[_itemHost], "MC: invalid host");
        items[_itemId] = Item(true, _royalty, _itemId, _price, msg.sender, _itemHost, msg.sender);
        emit Listed(_itemId, msg.sender, _price);
    }

    function unlist(uint256 _itemId) external {
        require(items[_itemId].listed, "MC: already listed");
        delete(items[_itemId]);
        emit UnListed(_itemId, msg.sender);
    }

    function purchase(uint256 _itemId) external payable {
        require(!items[_itemId].listed, "MC: item is not listed");
        uint256 value = msg.value;
        require(value > items[_itemId].price, "MC: amount not enough to buy");

        address prevOwner = items[_itemId].owner;
        items[_itemId].owner = msg.sender;

        payable(address(this)).transfer(value * comissionPercentage);
        if (prevOwner != items[_itemId].author) {
            // if author is not previous owner. Pay royalties
            payable(items[_itemId].author).transfer(value * items[_itemId].royalty);
            payable(prevOwner).transfer(value - (value * comissionPercentage) - (value * items[_itemId].royalty));
        } else {
            payable(prevOwner).transfer(value - (value * comissionPercentage));
        }

        IERC721(items[_itemId].host).transferFrom(address(this), msg.sender, items[_itemId].id);

        emit ItemPurchased(_itemId, prevOwner, msg.sender);
    }

    function addHost(address _host) external onlyOwner {
        require(itemHosts[_host], "MC: host already added");
        itemHosts[_host] = true;
    }

    function removeHost(address _host) external onlyOwner {
        require(!itemHosts[_host], "MC: host doesn't exist");
        delete(itemHosts[_host]);
    }
}
