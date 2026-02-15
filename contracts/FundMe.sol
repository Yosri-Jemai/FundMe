// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {PriceConverter} from "./PriceConverter.sol";


contract FundMe {
    using PriceConverter for uint256;

    uint256 public minUSD = 5e18;

    address[] funders;
    mapping (address funder => uint256 amountFunded) public addressToAmountFunded;

    address public owner;

    // Executed only once at deployment
    constructor(){
        owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConvertionRate() >= minUSD, "Minimum funding amount not met");
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (uint256 index = 0; index < funders.length; index++){
            address funder = funders[index];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Transaction failed");
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can withdraw");
        _;
    }

}