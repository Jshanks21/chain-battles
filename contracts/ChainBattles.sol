// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Strings for uint16;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    uint256 private initialNumber;

    struct Stats {
        uint256 level;
        uint256 life;
        uint256 strength;
        uint256 speed;
    }

    mapping(uint256 => Stats) public tokenIdToStats;

    constructor() ERC721("Chain Battles", "CBTLS") {}

    function createPseudoRandom(uint number) private returns(uint256){
        return uint256(keccak256(abi.encodePacked(initialNumber++))) % number;
    }

    function getStats(uint256 tokenId) public view returns (Stats memory) {
        Stats memory stats = tokenIdToStats[tokenId];
        return stats;
    }

    function generateCharacter(
        uint256 tokenId
    ) public view returns (string memory) {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Warrior",
            "</text>",
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Level: ",
            (getStats(tokenId).level).toString(),
            "</text>",
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Life: ",
            (getStats(tokenId).life).toString(),
            "</text>",
            '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Strength: ",
            (getStats(tokenId).strength).toString(),
            "</text>",
            '<text x="50%" y="80%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Speed: ",
            (getStats(tokenId).speed).toString(),
            "</text>",
            "</svg>"
        );
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Chain Battles #',
            tokenId.toString(),
            '",',
            '"description": "Battles on chain",',
            '"image": "',
            generateCharacter(tokenId),
            '"',
            "}"
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        tokenIdToStats[newItemId] = Stats(0, 10, 10, 10);
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function train(uint256 tokenId) public {
        require(_exists(tokenId), "Please use an existing token");
        require(
            ownerOf(tokenId) == msg.sender,
            "You must own this token to train it"
        );

        uint256 currentLevel = tokenIdToStats[tokenId].level;
        uint256 currentLife = tokenIdToStats[tokenId].life;
        uint256 currentStrength = tokenIdToStats[tokenId].strength;
        uint256 currentSpeed = tokenIdToStats[tokenId].speed;

        tokenIdToStats[tokenId].level = currentLevel + 1;
        tokenIdToStats[tokenId].life = currentLife + createPseudoRandom(100);
        tokenIdToStats[tokenId].strength = currentStrength + createPseudoRandom(100);
        tokenIdToStats[tokenId].speed = currentSpeed + createPseudoRandom(100);
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }
}