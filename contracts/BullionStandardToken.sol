pragma solidity ^0.8.17;

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

    address public owner;
    string public name;
    string public symbol;
    string public decimals;

    address public exchangeProxy; 
    WETH public weth;

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
    * 1. Grant allowance 
    * 2. Execute ERC20 swap
    * 3. Transfer any leftover ETH (protocol fee refunds) to sender.
    */
    function swap(
        ERC20 sellToken,
        ERC20 buyToken,
        address payable spender,
        address payable swapTarget, 
        bytes calldata swapData
        ) public onlyOwner payable {

        //1
        require(sellToken.approve(spender, uint256(-1)), "approve failed");

        //2
        (bool success ) = swapTarget.call{value: msg.value}(swapData);
        require(success, 'SWAP_CALL_FAILED');

        //3
        msg.sender.transfer(address(this).balance);
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
        msg.sender.transfer(_amount);
    }

    /**
    * @dev Withdraw tokens held by the contract to the owner
    */
    function withdrawToken(ERC20 _token, uint256 _amount) public onlyOwner {
        require(_token.transfer(msg.sender, _amount), "withdraw failed");
    }



    receive() external payable {    }
}