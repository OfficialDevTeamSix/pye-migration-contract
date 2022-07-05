// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./libraries/SafeBEP20.sol";

contract MultiMigration is Ownable, ReentrancyGuard {
    using SafeBEP20 for IBEP20;
    using SafeMath for uint256;

    uint256 accuracyFactor = 10**18;
    uint256 divisor = 10**18;

    address public immutable oldPYE = 0x4d542De559D9696cbC15a3937Bf5c89fEdb5b9c7;
    address public immutable oldMINI = 0xBa07EED3d09055d60CAEf2bDfCa1c05792f2dFad;
    address public immutable oldFORCE = 0xEcE3D017A62b8723F3648a9Fa7cD92f603E88a0E;
    address public immutable oldBULL = 0xA354F2185f8240b04f3f3C7b56A8Cd66F00b58db;
    
    address public immutable oldAPPLE = 0x5a83d81daCDcd3f5a5A712823FA4e92275d8ae9F;
    address public immutable oldTRICK = 0xE5F8Ea8A9081f7CaBb9D155Fb12B599E30c32AFE;
    address public immutable oldFUEL = 0xc4a21f59628c82Ff916F2267ad97f250A572DB4b;
    address public immutable oldRIDE = 0x10A0ddd99ff720BE0f247995d0E43CbaBd14D466;

    address public immutable oldCHERRY = 0xc1D6A3ef07C6731DA7FDE4C54C058cD6e371dA04;
    address public immutable oldTREAT = 0x4c091d0cbdCaF7eA2Bdd3beD7b0E787A95B9b483;
    address public immutable oldGRAVITY = 0x8B9386354C6244232e44E03932f2484b37fB94E2;
    address public immutable oldCHARGE = 0xA0340e9261C120708FD74b644A9Ff2D339B3eaee;

    uint256 public pyeRate;
    uint256 public miniRate;
    uint256 public forceRate;
    uint256 public bullRate;

    address public newPYE;
    address public newAPPLE;
    address public newPEACH;
    address public newCHERRY;

    address deadWallet = 0x000000000000000000000000000000000000dEaD;

    event NewTokenTransfered(address indexed operator, IBEP20 newToken, uint256 sendAmount);

    // update migrate info    
    function setConversionRates(uint256 _pyeRate, uint256 _miniRate, uint256 _forceRate, uint256 _bullRate) external onlyOwner{    
        pyeRate = _pyeRate;
        miniRate = _miniRate;
        forceRate = _forceRate;
        bullRate = _bullRate;
    }

    function setNewTokens(address _newPYE, address _newAPPLE, address _newPEACH, address _newCHERRY) external onlyOwner{
        newPYE = _newPYE;
        newAPPLE = _newAPPLE;
        newPEACH = _newPEACH;
        newCHERRY = _newCHERRY;
    }

    function handlePYE(address account) internal {
        uint256 PYE1;
        uint256 PYE2;
        uint256 PYE3;
        uint256 PYE4;

        uint256 oldPYEAmount = IBEP20(oldPYE).balanceOf(account);
        uint256 oldMINIAmount = IBEP20(oldMINI).balanceOf(account);
        uint256 oldFORCEAmount = IBEP20(oldFORCE).balanceOf(account);
        uint256 oldBULLAmount = IBEP20(oldBULL).balanceOf(account);

        if(oldPYEAmount > 0) {
            PYE1 = oldPYEAmount.mul(accuracyFactor).div(pyeRate).div(divisor);
            IBEP20(oldPYE).safeTransferFrom(account, deadWallet, oldPYEAmount);
        }
        if(oldMINIAmount > 0) {
            PYE2 = oldMINIAmount.mul(accuracyFactor).div(miniRate).div(divisor);
            IBEP20(oldMINI).safeTransferFrom(account, deadWallet, oldMINIAmount);
        }
        if(oldFORCEAmount > 0) {
            PYE3 = oldFORCEAmount.mul(accuracyFactor).div(forceRate).div(divisor);
            IBEP20(oldFORCE).safeTransferFrom(account, deadWallet, oldFORCEAmount);
        }
        if(oldBULLAmount > 0) {
            PYE4 = oldBULLAmount.mul(accuracyFactor).div(bullRate).div(divisor);
            IBEP20(oldBULL).safeTransferFrom(account, deadWallet, oldBULLAmount);
        }
        uint256 newPYEAmount = PYE1 + PYE2 + PYE3 + PYE4;

        if(newPYEAmount > 0) {
            IBEP20(newPYE).safeTransfer(account, newPYEAmount);
            emit NewTokenTransfered(account, IBEP20(newPYE), newPYEAmount); 
        }
    }

    function handleAPPLE(address account) internal {
        uint256 oldAPPLEAmount = IBEP20(oldAPPLE).balanceOf(account);
        uint256 oldTRICKAmount = IBEP20(oldTRICK).balanceOf(account);
        uint256 oldFUELAmount = IBEP20(oldFUEL).balanceOf(account);
        uint256 oldRIDEAmount = IBEP20(oldRIDE).balanceOf(account);

        if(oldAPPLEAmount > 0) {
            IBEP20(oldAPPLE).safeTransferFrom(account, deadWallet, oldAPPLEAmount);
        }
        if(oldTRICKAmount > 0) {
            IBEP20(oldTRICK).safeTransferFrom(account, deadWallet, oldTRICKAmount);
        }
        if(oldFUELAmount > 0) {
            IBEP20(oldFUEL).safeTransferFrom(account, deadWallet, oldFUELAmount);
        }
        if(oldRIDEAmount > 0) {
            IBEP20(oldRIDE).safeTransferFrom(account, deadWallet, oldRIDEAmount);
        }
        uint256 newAPPLEAmount = oldAPPLEAmount + oldTRICKAmount + oldFUELAmount + oldRIDEAmount;

        if(newAPPLEAmount > 0) {
            IBEP20(newAPPLE).mint(account, newAPPLEAmount);
            emit NewTokenTransfered(account, IBEP20(newAPPLE), newAPPLEAmount);  
        }
    }

    function handlePEACHERRY(address account) internal {
        uint256 oldCHERRYAmount = IBEP20(oldCHERRY).balanceOf(account);
        uint256 oldTREATAmount = IBEP20(oldTREAT).balanceOf(account);
        uint256 oldGRAVITYAmount = IBEP20(oldGRAVITY).balanceOf(account);
        uint256 oldCHARGEAmount = IBEP20(oldCHARGE).balanceOf(account);

        if(oldCHERRYAmount > 0) {
            IBEP20(oldCHERRY).safeTransferFrom(account, deadWallet, oldCHERRYAmount);
            IBEP20(newCHERRY).mint(account, oldCHERRYAmount);
            emit NewTokenTransfered(account, IBEP20(newCHERRY), oldCHERRYAmount); 
        }
        if(oldTREATAmount > 0) {
            IBEP20(oldTREAT).safeTransferFrom(account, deadWallet, oldTREATAmount);
        }
        if(oldGRAVITYAmount > 0) {
            IBEP20(oldGRAVITY).safeTransferFrom(account, deadWallet, oldGRAVITYAmount);
        }
        if(oldCHARGEAmount > 0) {
            IBEP20(oldCHARGE).safeTransferFrom(account, deadWallet, oldCHARGEAmount);
        }
        uint256 newPEACHAmount = oldTREATAmount + oldGRAVITYAmount + oldCHARGEAmount;

        if(newPEACHAmount > 0) {
            IBEP20(newPEACH).mint(account, newPEACHAmount);
            emit NewTokenTransfered(account, IBEP20(newPEACH), newPEACHAmount);  
        }
    }

    // Migration
    function migration() external nonReentrant {
        require(msg.sender != deadWallet, "Not allowed to dead wallet");
        handlePYE(msg.sender);
        handleAPPLE(msg.sender);
        handlePEACHERRY(msg.sender);
    }

    // Withdraw rest or wrong tokens that are sent here by mistake
    function drainBEP20Token(IBEP20 token, uint256 amount, address to) external onlyOwner {
        if( token.balanceOf(address(this)) < amount ) {
            amount = token.balanceOf(address(this));
        }
        token.safeTransfer(to, amount);
    }
}