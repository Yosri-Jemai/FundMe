// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {PriceConverter} from "./PriceConverter.sol";

error NotOwner(address caller);
error MinimumFundingNotMet(uint256 sent, uint256 required);
error WithdrawFailed(uint256 balanceAttempted);

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18;

    address[] funders;
    mapping (address funder => uint256 amountFunded) public addressToAmountFunded;

    address public immutable i_owner;

    // Executed only once at deployment
    constructor(){
        i_owner = msg.sender;
    }

    function fund() public payable {
        uint256 amountToFund = msg.value.getConvertionRate();
        if (amountToFund < MINIMUM_USD) 
            revert MinimumFundingNotMet(amountToFund, MINIMUM_USD);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (uint256 index = 0; index < funders.length; index++){
            address funder = funders[index];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        if (!callSuccess) revert WithdrawFailed(address(this).balance);
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert NotOwner(msg.sender);
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

}