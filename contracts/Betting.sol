// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Betting {
    uint strike = 15000;
    uint finalPrice = 0;
    uint totalPayins = 0;
    uint totalSharesAbove = 0;
    uint totalSharesBelow = 0;
    mapping (address => uint) balances;
    mapping (address => uint) shares;
    mapping (address => bool) bettingOnAbove;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function bet(address depositAddress, uint amount, bool above) public {
        require(amount > 0, "Deposit an amount > 0 eth");
        require(balances[depositAddress] == 0, "Only 1 bet per address");
        balances[depositAddress] += amount;
        totalPayins += amount;
        uint share = calculateShare(amount);
        shares[depositAddress] += share;
        bettingOnAbove[depositAddress] = above;
        if (above) {
            totalSharesAbove += share;
        } else {
            totalSharesBelow += share;
        }

    }

    function getDaysLeft() public view returns(uint) {
        return (1672531199 - uint(block.timestamp)) / (60 * 60 * 24);
    }

    function getBalance(address depositAddress) public view returns(uint) {
        return balances[depositAddress];
    }

    function getShares(address depositAddress) public view returns(uint) {
        return shares[depositAddress];
    }

    function getCurrentTime() public view returns(uint) {
        return block.timestamp;
    }

    function calculateShare(uint amount) private view returns(uint) {
        return amount + amount * getDaysLeft() / 365;
    }

    function setFinalPrice(uint price) public{
        require(msg.sender == owner, "This can only be called by the contract owner!");
        // Do stuff
        finalPrice = price;
    }

    function didWin(address depositAddress) public view returns(bool)  {
        require(finalPrice > 0, "The final price has not been set yet.");
        if (finalPrice > strike && bettingOnAbove[depositAddress] == true) {
            return true;
        } else if  (finalPrice < strike && bettingOnAbove[depositAddress] == false) {
            return true;
        }  else {
            return false;
        }
    }

    function getPayout(address depositAddress) public view returns(uint) {
        bool won = didWin(depositAddress);
        require(won == true, "You did not win.");
        if (won == true && finalPrice > strike) {
            return totalPayins * shares[depositAddress] / totalSharesAbove;
        } else if (won == true && finalPrice < strike) {
            return totalPayins* shares[depositAddress] / totalSharesBelow;
        } else {
            return 0;
        }
    }


}
