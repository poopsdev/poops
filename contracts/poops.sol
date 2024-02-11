//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ERC404} from "./ERC404.sol";

contract Poops is ERC404, ReentrancyGuard {
    /// @dev Merkle Proof root
    bytes32 public merkleRoot = 0xb26515f4981384eb34c45033c291362b3ae88b50dd250e8203faa2236c3d921a;
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
    ) internal override checkWhitelist {
        return super._mint(to);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override checkWhitelist returns (bool){
        return super._transfer(from, to, amount);
    }

    function setTokenURI(string memory _tokenURI) external onlyOwner {
        baseTokenURI = _tokenURI;
    }

    function addToInternalWhitelist(bytes32[] calldata _merkleProof) public view {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), "failed to proof a wallet");
        internalWhitelist[msg.sender] == true;
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

