// SPDX-Licence-Identifier : MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract MintAnimalToken is ERC721Enumerable{
    constructor() ERC721("IANAnimals", "IAN"){}

    mapping(uint256 => string) private animal;
    mapping(uint256 => uint256) public animalTypes;
    // mapping이란?
    // 매핑은 일반적인 프로그래밍 언어에서는 해시테이블이나 사전과 유사합니다.
    // 키(Key) - 값(value) 형태로 쌍으로 저장되고 제공된 키(Key)를 가지고 값(value)을 얻어낼 수 있습니다.
    // tokenId를 입력하면 animalType이 반환된다.

    function mintAnimalToken() public { 
        uint256 animalTokenId = totalSupply() + 1;

        uint256 animalType = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, animalTokenId))) % 5 + 1; 
        //keccak256을 사용하기 위해서 byte코드가 필요하다.
        //값 3개를 합쳐서 해쉬화하한 랜덤값이 나온다.
        //%5 하면 0-4까지의 값이 나오고 + 1 => 부터 5의 랜덤값 뽑기

        //랜덤값을 매핑에 집어넣기
        animalTypes[animalTokenId] = animalType;
        _mint(msg.sender, animalTokenId);
    }

}