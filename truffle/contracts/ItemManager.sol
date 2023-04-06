// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "./Ownable.sol";
import "./Item.sol";

contract ItemManager is Ownable {

    enum SupplyChainState{
        Created, 
        Paid, 
        Delivered
    }

    struct SupplyItem {
        Item _item;
        string _identifier;
        uint _itemPrice;
        ItemManager.SupplyChainState _state;
    }

    uint itemIndex;
    // Map to a supply item
    mapping(uint => SupplyItem) public items;
    event SupplyChainStep(uint _itemIndex, uint _step);

    // Create new item
    function createItem(string memory identifier, uint itemPrice) public onlyOwner {
        Item item = new Item(this, itemPrice, itemIndex);
        items[itemIndex]._item = item;
        items[itemIndex]._identifier = identifier;
        items[itemIndex]._itemPrice = itemPrice;
        items[itemIndex]._state = SupplyChainState.Created;

        //Emit evemt
        emit SupplyChainStep(itemIndex, uint(items[itemIndex]._state));
        
        //Incriment Index
        itemIndex++;
    }

    // Trigger payment to item
    function triggerPayment(uint _itemIndex) public payable {
        require(items[_itemIndex]._itemPrice == msg.value, "Only full payments are accepted");
        require(items[_itemIndex]._state == SupplyChainState.Created, "Item is already in progress");

        //Emit event
        emit SupplyChainStep(_itemIndex, uint(items[_itemIndex]._state));
        // Set supply chain state to paid
        items[itemIndex]._state = SupplyChainState.Paid;
    }

    function triggerDelivery(uint _itemIndex) public onlyOwner{
        require(items[_itemIndex]._state == SupplyChainState.Paid, "Item is not paid for");

        // Set supply chain state to paid
        items[_itemIndex]._state = SupplyChainState.Delivered;

        //Emit event
        emit SupplyChainStep(_itemIndex, uint(items[_itemIndex]._state));
    }
}