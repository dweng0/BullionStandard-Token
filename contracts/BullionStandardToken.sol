// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// A partial ERC20 interface.
interface ERC20 {
    function balanceOf(address owner) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
}

// A partial WETH interfaec.
interface WETH is ERC20 {
    function deposit() external payable;
}

/**
* @title BullionStandard 
* @dev The BS token
*/
contract BullionStandard {

    // allow unlimited approval 
    uint256 public constant MASK = type(uint128).max;
    address public owner;
    string public name;
    string public symbol;
    string public decimals;

    address public exchangeProxy; 
    WETH public weth;

    event BoughtTokens(ERC20 sellToken, ERC20 buyToken, uint256 buyAmount);

    constructor(WETH _weth, address _exchangeProxy) {

        // ownership
        owner = msg.sender;

        // basic erc20 compliance
        name = "Bullion Standard";
        symbol = "BS";
        decimals = "18";

        // set up weth & proxy
        weth = _weth;
        exchangeProxy = _exchangeProxy;
    }

    /**
    * @dev basic modifier to check ownership
    */
    modifier onlyOwner {
      require(msg.sender == owner);
      _;
   }

    /**
    * @dev  Steps:
    * 1. security checks
    * 2. Execute ERC20 swap
    * 3. Transfer any leftover ETH (protocol fee refunds) to sender.
    * 4. Emit event.
    */
    function swap(
        ERC20 sellToken,
        ERC20 buyToken,
        address spender,
        address swapTarget, 
        bytes calldata swapData
        ) public onlyOwner payable {

        //1
        require(sellToken.approve(spender, MASK), "approve failed");
        require(swapTarget == exchangeProxy, "Please target the exchange proxy");

         uint256 boughtAmount = buyToken.balanceOf(address(this));

        //2
        (bool success, ) = swapTarget.call{value:msg.value}(swapData);
        require(success, 'SWAP_CALL_FAILED');

        //3
        payable(msg.sender).transfer(address(this).balance);

        // Use our current buyToken balance to determine how much we've bought.
        boughtAmount = buyToken.balanceOf(address(this)) - boughtAmount;
        emit BoughtTokens(sellToken, buyToken, boughtAmount);
    }

    /**
    * @dev Deposit ETH and wrap it into WETH, this is required for the swap.
    */
    function depositETHAndWrap() public payable {
        weth.deposit{value: msg.value}();
    }

    /**
    * @dev Withdraw ETH held by the contract to the owner
    */
    function withdrawETH(uint256 _amount) public onlyOwner {
        payable(msg.sender).transfer(_amount);
    }

    /**
    * @dev Withdraw tokens held by the contract to the owner
    */
    function withdrawToken(ERC20 _token, uint256 _amount) public onlyOwner {
        require(_token.transfer(msg.sender, _amount), "withdraw failed");
    }



    receive() external payable {    }
}