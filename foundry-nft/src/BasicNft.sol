// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract BasicNft is ERC721 {
    uint256 private s_tokenCounter; // 用于生成唯一的token id
    mapping(uint256 => string) private s_tokenToUri; // 用于存储token uri

    constructor() ERC721("Dogie", "DOG") {
        s_tokenCounter = 0;
    }
    // 铸币函数
    // @param _to 地址
    function mintNft(string memory uri) public {
        s_tokenToUri[s_tokenCounter] = uri;
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter++;
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        return s_tokenToUri[_tokenId];
    }

}