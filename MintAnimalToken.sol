// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "SaleAnimalToken.sol";

contract MintAnimalToken is ERC721Enumerable {
    constructor() ERC721("MINT", "IAN") {}

    SaleAnimalToken public saleAnimalToken;

    mapping(uint256 => uint256) public animalTypes;
    // mapping이란?
    // 매핑은 일반적인 프로그래밍 언어에서는 해시테이블이나 사전과 유사합니다.
    // 키(Key) - 값(value) 형태로 쌍으로 저장되고 제공된 키(Key)를 가지고 값(value)을 얻어낼 수 있습니다.
    // tokenId를 입력하면 animalType이 반환된다.

    //외부 함수 사용을 위해
    struct AnimalTokenData {
        uint256 animalTokenId;
        uint256 animalType;
        uint256 animalPrice;
    }

    function mintAnimalToken() public {
        //총 발행량의 + 1 => 유일한 값
        uint256 animalTokenId = totalSupply() + 1; 

        uint256 animalType = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, animalTokenId))) % 5 + 1;
        //keccak256을 사용하기 위해서 byte코드가 필요하다.
        //값 3개를 합쳐서 해쉬화된 랜덤값이 나온다.
        //%5 하면 0-4까지의 값이 나오고 + 1 => 부터 5의 랜덤값 뽑기

        //랜덤값을 매핑에 집어넣기
        animalTypes[animalTokenId] = animalType;

        //ERC721에서 제공해주는 minting 함수
        //이 명령어를 실행한 사람 => 민팅 버튼 누른 사람
        _mint(msg.sender, animalTokenId);
    }

    //리팩토링 함수 => 재 deploy
    //리턴 타입 memory 명시(storage => 영구 저장, memory => 임시)
    function getAnimalTokens(address _animalTokenOwner) view public returns (AnimalTokenData[] memory) {
        
        //소유갯수 체크
        uint256 balanceLength = balanceOf(_animalTokenOwner);
        
        require(balanceLength != 0, "Owner did not have token.");

        //balanceLength 배열 생성
        AnimalTokenData[] memory animalTokenData = new AnimalTokenData[](balanceLength);

        //
        for(uint256 i = 0; i < balanceLength; i++) {
            // 토큰 아이디, types, price 가져오기
            uint256 animalTokenId = tokenOfOwnerByIndex(_animalTokenOwner, i);
            uint256 animalType = animalTypes[animalTokenId];
            //saleAnimal Token은 mintAnimalToken deploy 후 생성하기 때문에 생성자 단계에서 생성할 수 없다.
            //import 후 SaleAnimalToken saleAnimalToken 생성 후 함수(setSaleAnimalToken)를 하나 더 만들어주어야한다. 
            //getAnimalTokenPrice함수(mintAnimalToken내에서 struct 생성)를 saleAnimalToken.sol 내에서 생성해주어야 한다.

            uint256 animalPrice = saleAnimalToken.getAnimalTokenPrice(animalTokenId);

            animalTokenData[i] = AnimalTokenData(animalTokenId, animalType, animalPrice);
        }

        return animalTokenData;
    }
    
    // import 후 SaleAnimalToken saleAnimalToken 생성 후 함수를 하나 더 만들어주어야한다. 
    // 사용은 remix에서 setSaleAnimalToken 따로 설정 
    function setSaleAnimalToken(address _saleAnimalToken) public {
        saleAnimalToken = SaleAnimalToken(_saleAnimalToken);
    }
}