// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "MintAnimalToken.sol";

contract SaleAnimalToken {

    //deploy한 주소를 담는다.
    MintAnimalToken public mintAnimalTokenAddress;

    constructor (address _mintAnimalTokenAddress) {
        mintAnimalTokenAddress = MintAnimalToken(_mintAnimalTokenAddress);
    }


    mapping(uint256 => uint256) public animalTokenPrices; //tokenId를 입력하면 가격을 리턴한다.

    //프론트엔드에서 어떤게 판매중인 토큰인지 알 수 있도록 배열 생성   
    uint256[] public onSaleAnimalTokenArray;

    

    function setForSaleAnimalToken(uint256 _animalTokenId, uint256 _price) public { //다 참조할 수 있게끔 퍼블릭 처리
        address animalTokenOwner = mintAnimalTokenAddress.ownerOf(_animalTokenId); //토큰 아이디 값으로 주인 주소 식별

        //true 일떄 , 뒤에 실행하고 funcrion setForSaleAnimalToken 실행 종료
        //require안에 있는 내용이 거짓이면 실행 중단
        require(animalTokenOwner == msg.sender, "Caller is not animal token owner."); //토큰 주인이 판매요청 한 사람과 동일한지 알려주는 함수
        require(_price > 0, "Price is zero or lower."); //가격이 0보다 크게 넣을 지 확인
        require(animalTokenPrices[_animalTokenId] == 0, "This animal token is already on sale."); //값이 0일 경우 유효하지 않다. 이미 팔린 토큰인지 확인
        require(mintAnimalTokenAddress.isApprovedForAll(animalTokenOwner, address(this)), "Animal token owner did not approve token."); //위임 권한 확인
        //(token주인, SaleAnimalToken Contract의 주소) 주인이 판매계약서에 판매 권한을 넘겼는지, 다른 스마트 컨트랙트로 넘어가게 하지 않기 위해
        //boolean값으로 반환됨.
        //setApprovedforAll = true처리

        //_animalTokenId에 해당하는 값을 넣어주기
        animalTokenPrices[_animalTokenId] = _price;

        //프론트엔드에서 보여주기 위해
        onSaleAnimalTokenArray.push(_animalTokenId);
    }

    
    //구매 처리
    function purchaseAnimalToken(uint256 _animalTokenId) public payable {
        
        // 토큰 아이디값 => 가격 조회
        uint256 price = animalTokenPrices[_animalTokenId];

        // token owner address = tokenId owner 뽑아오기
        address animalTokenOnwer = mintAnimalTokenAddress.ownerOf(_animalTokenId);

        require(price > 0, "Animal token not sale."); //
        require(price <= msg.value, "Caller sent lower than price."); //
        require(animalTokenOnwer != msg.sender, "Caller is animal token owner.");

        payable(animalTokenOnwer).transfer(msg.value);
        mintAnimalTokenAddress.safeTransferFrom(animalTokenOnwer, msg.sender, _animalTokenId);

        animalTokenPrices[_animalTokenId] = 0;

        for(uint256 i = 0; i < onSaleAnimalTokenArray.length; i++) {
            if(animalTokenPrices[onSaleAnimalTokenArray[i]] == 0) {
                onSaleAnimalTokenArray[i] = onSaleAnimalTokenArray[onSaleAnimalTokenArray.length - 1];
                onSaleAnimalTokenArray.pop();
            }
        }
    }

    function getOnSaleAnimalTokenArrayLength() view public returns (uint256) {
        return onSaleAnimalTokenArray.length;
    }

    function getAnimalTokenPrice(uint256 _animalTokenId) view public returns (uint256) {
        return animalTokenPrices[_animalTokenId];
    }

}