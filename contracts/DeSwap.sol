// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.9;
import './Token.sol';

/**
* @title DeSwap
* @dev DeSwap is a simple PoC decentralized exchange for ERC20 tokens.
*/
contract DeSwap { 

    Token public token;
    uint public rate = 100;

    event TokenPurchased(
        address account,
        address token,
        uint amount,
        uint rate
    );

    event TokenSold(
        address account,
        address token,
        uint amount,
        uint rate
    );

    constructor(Token _token) {
        token = _token;
    }

    /**
    * @dev Buys tokens with Ether
    */
    function buyTokens() public payable {
        // Calculate the number of tokens to buy basedon the exchange rate
        uint tokenAmount = msg.value * rate;

        // Require that DeSwap has enough tokens
        require(token.balanceOf(address(this)) >= tokenAmount);

        // Transfer tokens to the user
        token.transfer(msg.sender, tokenAmount);

        // Emit an event
        emit TokenPurchased(msg.sender, address(token), tokenAmount, rate);
    }

    /**
    * @dev Sells tokens for Ether
    */
    function sellTokens(uint _amount) public {
        // User can't sell more tokens than they have
        require(token.balanceOf(msg.sender) >= _amount);

        // Calculate the amount of the ether to redeem
        uint etherAmount = _amount / rate;

        // Require that DeSwap has enough ether
        require(address(this).balance >= etherAmount);

        // Perform sale
        token.transferFrom(msg.sender, address(this), _amount);
        payable(msg.sender).transfer(etherAmount);

        // Emit an event
        emit TokenSold(msg.sender, address(token), _amount, rate);
    }
}