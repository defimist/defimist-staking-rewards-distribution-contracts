// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.6.12;

import "./IRewardTokensValidator.sol";
import "defimist-dmdao-token-registry/contracts/DMTokenRegistry.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DefaultRewardTokensValidator is IRewardTokensValidator, Ownable {
    DMTokenRegistry public dmTokenRegistry;
    uint256 public dmTokenRegistryListId;

    constructor(address _dmTokenRegistryAddress, uint256 _dmTokenRegistryListId)
        public
    {
        require(
            _dmTokenRegistryAddress != address(0),
            "DefaultRewardTokensValidator: 0-address token registry address"
        );
        require(
            _dmTokenRegistryListId > 0,
            "DefaultRewardTokensValidator: invalid token list id"
        );
        dmTokenRegistry = DMTokenRegistry(_dmTokenRegistryAddress);
        dmTokenRegistryListId = _dmTokenRegistryListId;
    }

    function setDMTokenRegistry(address _dmTokenRegistryAddress)
        external
        onlyOwner
    {
        require(
            _dmTokenRegistryAddress != address(0),
            "DefaultRewardTokensValidator: 0-address token registry address"
        );
        dmTokenRegistry = DMTokenRegistry(_dmTokenRegistryAddress);
    }

    function setDMTokenRegistryListId(uint256 _dmTokenRegistryListId)
        external
        onlyOwner
    {
        require(
            _dmTokenRegistryListId > 0,
            "DefaultRewardTokensValidator: invalid token list id"
        );
        dmTokenRegistryListId = _dmTokenRegistryListId;
    }

    function validateTokens(address[] calldata _rewardTokens)
        external
        view
        override
    {
        require(
            _rewardTokens.length > 0,
            "DefaultRewardTokensValidator: 0-length reward tokens array"
        );
        for (uint256 _i = 0; _i < _rewardTokens.length; _i++) {
            address _rewardToken = _rewardTokens[_i];
            require(
                _rewardToken != address(0),
                "DefaultRewardTokensValidator: 0-address reward token"
            );
            require(
                dmTokenRegistry.isTokenActive(
                    dmTokenRegistryListId,
                    _rewardToken
                ),
                "DefaultRewardTokensValidator: invalid reward token"
            );
        }
    }
}
