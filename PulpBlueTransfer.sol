// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PulpBlue is ERC721, Ownable {
  using Strings for uint256;
  using Counters for Counters.Counter;

  Counters.Counter private _tokenIdCounter;

  string[] public baseValues = ["frontier","homestead","metropolis","byzantium","constantinople","serenity","samsara","nirvana","anatta","ochre","horizons","rupa","vedana","sanna","sankhara","vinnana"];

  struct Word {
    string name;
    string description;
    string btcNumber;
    string MumNumber;
    string DadNumber;
    string value;
  }

    // Mapping
    mapping (uint256 => Word) public attributes;
    mapping (uint256 => uint256) private _transferCounts;
    mapping(uint256 => uint256[][2]) public circleLocations;

  constructor() ERC721("PulpBlue", "BLUE") {
      _safeMint(msg.sender, 1);
      Word memory newWord = Word(
        string(abi.encodePacked('Pulp Based Blue')),
        "Generate a circle. Pass it on. 10th receiver collects.",
        randomNum(21000000, block.timestamp, 1, 0, 100).toString(),
        randomNum(90, 10011955, block.timestamp, 0, 100).toString(),
        randomNum(90, 12081951, block.timestamp, 0, 100).toString(),
        string(
          abi.encodePacked(
            baseValues[randomNum(baseValues.length, block.timestamp, 1, 0, 100)]
          )
        )
      );
      attributes[1] = newWord;
  }

  function transfer(address _to, uint256 _tokenId) public virtual {
    require(_transferCounts[_tokenId] < 10, "Transfer count exceeded");

    if (_transferCounts[_tokenId] == 9) {
        uint256 contractBalance = address(this).balance;
        (bool success, ) = _to.call{value: contractBalance}("");
        require(success, "Transfer failed.");
    }

    _transferCounts[_tokenId]++;
    super.transferFrom(msg.sender, _to, _tokenId);
}

  function randomNum(uint256 _mod, uint256 _seed, uint256 _salt, uint256 _minMod, uint256 _tokenId) public view returns(uint256){
    require(_mod >= _minMod, "Mod value too small");
    uint256 num = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, _seed, _salt, _tokenId))) % _mod;
    return num;
}

  function buildImage(uint256 _tokenId) public view returns(string memory) {
    uint256[] memory xCoords = new uint256[](100);
    uint256[] memory yCoords = new uint256[](100);

    for (uint i = 0; i < _transferCounts[_tokenId]; i++) {
        xCoords[i] = randomNum(450, block.timestamp, i + 2, 0, _tokenId);
        yCoords[i] = randomNum(450, block.timestamp, i + 3, 0, _tokenId);
    }

    string memory circles = "";
    for (uint i = 0; i < _transferCounts[_tokenId]; i++) {
        circles = string(abi.encodePacked(circles, '<circle cx="', xCoords[i].toString(), '" cy="', yCoords[i].toString(), '" r="35" fill="blue" opacity="70%"/>'));
    }

    return Base64.encode(bytes(abi.encodePacked(
        '<svg width="100%" height="500" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 500">',
        '<g fill="none">',
        '<rect x="0" y="0" width="500" height="500"/>',
        '</g>',
        circles,
        '</svg>'
     )));
} 


  function tokenURI(uint256 _tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(_tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    Word memory currentWord = attributes[_tokenId];

    return string(abi.encodePacked(
      'data:application/json;base64,', Base64.encode(bytes(abi.encodePacked(
        '{"name":"',
        currentWord.name,
        '", "description":"',
        currentWord.description,
        '", "attributes": [{"trait_type": "btcNumber", "value": "',
        currentWord.btcNumber,
        '"}, {"trait_type": "MumNumber", "value": "',
        currentWord.MumNumber,
        '"}, {"trait_type": "DadNumber", "value": "',
        currentWord.DadNumber,
        '"}, {"trait_type": "Intention", "value": "',
        currentWord.value,
        '"}], "image": "',
        'data:image/svg+xml;base64,',
        buildImage(_tokenId),
        '"}')))));
  }


}