//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ERC404} from "./ERC404.sol";

contract Poops is ERC404, Pausable, ReentrancyGuard {
    /// @dev token uri for data location
    string public baseTokenURI;
    /// @dev contract start time stamp
    uint public stamp;
    /// @dev Addresses whitelisted for NFT buying
    mapping(address => bool) public internalWhitelist;

    modifier checkWhitelist() {
        if (isWhitelistTime(block.timestamp)){
            require(internalWhitelist[msg.sender] == true, "checkWhitelist: user is not in whitelist");
        }
        _ ;
    }
    
    constructor(address _owner) ERC404("Poops404", "POOPS", 18, 10_000, _owner) {
        balanceOf[_owner] = totalSupply;
        stamp = block.timestamp;
    }
    
    function _mint(
        address to
    ) internal override whenNotPaused {
        return super._mint(to);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused checkWhitelist returns (bool){
        return super._transfer(from, to, amount);
    }

    function setTokenURI(string memory _tokenURI) external onlyOwner {
        baseTokenURI = _tokenURI;
    }

    function addToInternalWhitelist(address wallet) external onlyOwner {
        internalWhitelist[wallet] = true;
    }

    function setNameSymbol(
        string memory _name,
        string memory _symbol
    ) external onlyOwner {
        _setNameSymbol(_name, _symbol);
    }
    
    function tokenURI(uint256 id) public view override returns (string memory) {
        require(bytes(baseTokenURI).length > 0);
        return string.concat(baseTokenURI, Strings.toString(id), ".json");
    }

    function isWhitelistTime(uint timestamp) view public returns (bool res) {
        res = timestamp < stamp + (5 minutes);
    }
}

