// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.6.12;

import "./IStakableTokenValidator.sol";
import "defimist-core/contracts/interfaces/IDefimistPair.sol";
import "defimist-core/contracts/interfaces/IDefimistFactory.sol";
import "defimist-dmdao-token-registry/contracts/DMTokenRegistry.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DefaultStakableTokenValidator is IStakableTokenValidator, Ownable {
    DMTokenRegistry public dmTokenRegistry;
    uint256 public dmTokenRegistryListId;
    IDefimistFactory public defimistFactory;

    constructor(
        address _dmTokenRegistryAddress,
        uint256 _dmTokenRegistryListId,
        address _defimistFactoryAddress
    ) public {
        require(
            _dmTokenRegistryAddress != address(0),
            "DefaultStakableTokenValidator: 0-address token registry address"
        );
        require(
            _dmTokenRegistryListId > 0,
            "DefaultStakableTokenValidator: invalid token list id"
        );
        require(
            _defimistFactoryAddress != address(0),
            "DefaultStakableTokenValidator: 0-address factory address"
        );
        dmTokenRegistry = DMTokenRegistry(_dmTokenRegistryAddress);
        dmTokenRegistryListId = _dmTokenRegistryListId;
        defimistFactory = IDefimistFactory(_defimistFactoryAddress);
    }

    function setDMTokenRegistry(address _dmTokenRegistryAddress)
        external
        onlyOwner
    {
        require(
            _dmTokenRegistryAddress != address(0),
            "DefaultStakableTokenValidator: 0-address token registry address"
        );
        dmTokenRegistry = DMTokenRegistry(_dmTokenRegistryAddress);
    }

    function setDMTokenRegistryListId(uint256 _dmTokenRegistryListId)
        external
        onlyOwner
    {
        require(
            _dmTokenRegistryListId > 0,
            "DefaultStakableTokenValidator: invalid token list id"
        );
        dmTokenRegistryListId = _dmTokenRegistryListId;
    }

    function setDefimistFactory(address _defimistFactoryAddress)
        external
        onlyOwner
    {
        require(
            _defimistFactoryAddress != address(0),
            "DefaultStakableTokenValidator: 0-address factory address"
        );
        defimistFactory = IDefimistFactory(_defimistFactoryAddress);
    }

    function validateToken(address _stakableTokenAddress)
        external
        view
        override
    {
        require(
            _stakableTokenAddress != address(0),
            "DefaultStakableTokenValidator: 0-address stakable token"
        );
        IDefimistPair _potentialDefimistPair = IDefimistPair(_stakableTokenAddress);
        address _token0;
        try _potentialDefimistPair.token0() returns (address _fetchedToken0) {
            _token0 = _fetchedToken0;
        } catch {
            revert(
                "DefaultStakableTokenValidator: could not get token0 for pair"
            );
        }
        require(
            dmTokenRegistry.isTokenActive(dmTokenRegistryListId, _token0),
            "DefaultStakableTokenValidator: invalid token 0 in Swapr pair"
        );
        address _token1;
        try _potentialDefimistPair.token1() returns (address _fetchedToken1) {
            _token1 = _fetchedToken1;
        } catch {
            revert(
                "DefaultStakableTokenValidator: could not get token1 for pair"
            );
        }
        require(
            dmTokenRegistry.isTokenActive(dmTokenRegistryListId, _token1),
            "DefaultStakableTokenValidator: invalid token 1 in Swapr pair"
        );
        require(
            defimistFactory.getPair(_token0, _token1) == _stakableTokenAddress,
            "DefaultStakableTokenValidator: pair not registered in factory"
        );
    }
}
