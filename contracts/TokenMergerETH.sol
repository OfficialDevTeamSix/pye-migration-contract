// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./libraries/SafeERC20.sol";

contract TokenMerger is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint256 divisor = 10**15;

    address public constant oldAPPLE = 0x5a83d81daCDcd3f5a5A712823FA4e92275d8ae9F;

    uint256 public appleRate = 104632;

    address public newPYE = 0x4d542De559D9696cbC15a3937Bf5c89fEdb5b9c7;

    address deadWallet = 0x000000000000000000000000000000000000dEaD;

    event NewTokenTransfered(address indexed operator, IERC20 newToken, uint256 sendAmount);

    // update migrate info    
    function setConversionRates(uint256 _appleRate, uint256 _peachRate) external onlyOwner{    
        appleRate = _appleRate;
        peachRate = _peachRate;
    }

    function setNewTokens(address _newPYE) external onlyOwner{
        newPYE = _newPYE;
    }

    function handlePYE(address account) internal {
        uint256 newPYEAmount = 0;

        uint256 oldAPPLEAmount = IERC20(oldAPPLE).balanceOf(account);

        if(oldAPPLEAmount > 0) {
            newPYEAmount += oldAPPLEAmount * appleRate / divisor;
            IERC20(oldAPPLE).safeTransferFrom(account, deadWallet, oldAPPLEAmount);
        }

        if(newPYEAmount > 0) {
            IERC20(newPYE).safeTransfer(account, newPYEAmount);
            emit NewTokenTransfered(account, IERC20(newPYE), newPYEAmount); 
        }
    }

    // Merging
    function mergeTokens() external nonReentrant {
        require(msg.sender != deadWallet, "Not allowed to dead wallet");
        handlePYE(msg.sender);
    }

    // Withdraw rest or wrong tokens that are sent here by mistake
    function drainERC20Token(IERC20 token, uint256 amount, address to) external onlyOwner {
        if( token.balanceOf(address(this)) < amount ) {
            amount = token.balanceOf(address(this));
        }
        token.safeTransfer(to, amount);
    }

    function getAmounts(address account) external view returns(
        uint256 appleBalance, 
        uint256 pyeFromApple, 
        uint256 pyeOwed
    ) {
        appleBalance = IERC20(oldAPPLE).balanceOf(account);
        pyeFromApple = appleBalance * appleRate / divisor;
        pyeOwed = pyeFromApple;
    }
}