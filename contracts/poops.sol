//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ERC404} from "./ERC404.sol";

contract Poops is ERC404 {
    string public baseTokenURI;
    
    constructor(address _owner) ERC404("Poops404", "POOPS", 18, 1_000, _owner) {
        balanceOf[_owner] = totalSupply;
    }

    function setTokenURI(string memory _tokenURI) external onlyOwner {
        baseTokenURI = _tokenURI;
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
}

