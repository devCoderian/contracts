// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "MintAnimalToken.sol";

contract SaleAnimalToken{
    // MintAnimalToken을 deploy하게 되면 deploy한 주소값을 담는다.
    MintAnimalToken public mintAnimalTokenAddress;
    constructor (address _mintAnimalTokenAddress){
        mintAnimalTokenAddress = MintAnimalToken(_mintAnimalTokenAddress);
    }

    mapping(uint256 => uint256) public animalTokenPrices; //animalTokenId를 입력하면 실제 가격을 리턴한다.

    //frontend에서 어떤게 판매중인 토큰인지 확인할 수 있도록 만든다.
    uint256[] public onSaleAnimalTokenArray;

    function setForSaleAnimalToken(uint256 _animalTokenId, uint256 _price) public{ //다 참조할 수 있게끔 public 처리
        address animalTokenOwner = mintAnimalTokenAddress.ownerOf(_animalTokenId); //토큰 아이디 값으로 주인이 누군지 알려주는 함수
            
        require(animalTokenOwner == msg.sender, "Caller is not animal token owner."); //토큰 주인이 판매요청 한 사람과 동일한지 알려주는 함수
        require(_price > 0, "Price is zero or lower."); // 가격이 0보다 크게 넣을 지 확인
        //3번째 조건 만들기 전 가격들을 관리하는 매핑
        require(animalTokenPrices[_animalTokenId] == 0, "This animal token is already on sale.");  //값이 0일 경우 유효하지 않다. 이미 팔린 토큰인지 확인
        require(mintAnimalTokenAddress.isApprovedForAll(animalTokenOwner, address(this)), "Animal token owner did not approve token."); //위임 권한 확인
        //isApprovedForAll(token주인, SaleAnimalToken Contract의 주소) 이 주인이 판매 계약서에 판매 권한을 넘겼는지, 다른 스마트 컨트랙트로 넘어가게 하지 않기 위해
        //boolean값으로 반환됨 true일때만 통과돼서 판매 등록이 될 수 있다. 

        
        animalTokenPrices[_animalTokenId] = _price;
        
        //front단 사용
        onSaleAnimalTokenArray.push(_animalTokenId); //판매중인 토큰은 animalTokenId를 집어넣는다.

    }

        //구매 함수
        function purchaseAnimalToken(uint256 _animalTokenId) public payable {
            uint256 price = animalTokenPrices[_animalTokenId];
            address animalTokenOwner = mintAnimalTokenAddress.ownerOf(_animalTokenId);
            
            require(price > 0, "Animal token not sale.");
            require(price <= msg.value, "Caller sent lower than price");
            require(animalTokenOwner != msg.sender, "Caller is animal token owner.");

            payable(animalTokenOwner).transfer(msg.value);

            mintAnimalTokenAddress.safeTransferFrom(animalTokenOwner, msg.sender, _animalTokenId);

            animalTokenPrices[_animalTokenId] = 0;
            
            for(uint256 i = 0; i<onSaleAnimalTokenArray.length; i++){
                if(animalTokenPrices[onSaleAnimalTokenArray[i]]== 0){
                    onSaleAnimalTokenArray[i] = onSaleAnimalTokenArray[onSaleAnimalTokenArray.length - 1];
                    onSaleAnimalTokenArray.pop();
                }
            }
        }

        function getOnSaleAnimalTokenArrayLength() view public returns(uint256){
            return onSaleAnimalTokenArray.length;
        }
}