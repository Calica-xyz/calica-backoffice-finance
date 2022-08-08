// SPDX-License-Identifier: CC-BY-NC-ND

pragma solidity ^0.8.7;

import "@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {RevenueShare} from "./RevenueShare.sol";
import {RevenueShareInput} from "../globals.sol";

contract RevenueShareFactory is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable
{
    address public implementationAddress;
    event ContractDeployed(address indexed owner, address indexed cloneAddress);

    function initialize() external initializer {
        implementationAddress = address(new RevenueShare());
        __Ownable_init();
    }

    // solhint-disable-next-line
    function _authorizeUpgrade(address) internal override onlyOwner {}

    function createNewRevenueShare(RevenueShareInput calldata input)
        external
        returns (address)
    {
        address memImplementationAddress = implementationAddress;

        require(
            memImplementationAddress != address(0),
            "Must be initialized first"
        );

        address payable cloneAddress = payable(
            ClonesUpgradeable.clone(memImplementationAddress)
        );

        emit ContractDeployed(msg.sender, cloneAddress);

        RevenueShare revenueShare = RevenueShare(cloneAddress);
        revenueShare.initialize(input);

        return cloneAddress;
    }
}
