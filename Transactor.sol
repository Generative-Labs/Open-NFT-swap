pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";


contract Transctor {

    event initializedExchange(bytes32);

    struct ExchangeMetaData {
        ERC20[] erc20sA;
        uint[] amountsA; 
        ERC721[] NFTA;
        uint[][] idA; 
        ERC20[] erc20sB; 
        uint[] amountsB;
        ERC721[] NFTB;
        uint[][] idB;  
        address A;
        address B;
        bool isAgreedByA;
        bool isComplete;
        bytes32 key;
        uint expiration;
    }

    mapping(address => mapping(address => ExchangeMetaData)) public exchangeData;


    function initializeExchange(
        ERC20[] memory erc20sA, uint[] memory amountsA, 
        ERC721[] memory NFTA, uint[][] memory idA,
        ERC20[] memory erc20sB, uint[] memory amountsB, 
        ERC721[] memory NFTB, uint[][] memory idB, address B, uint expiration) public returns (bytes32) {
        require(B != msg.sender, "cannot transact with self.");
        require(erc20sA.length == amountsA.length, "Length of tokens and token amounts not equal (A).");
        require(erc20sB.length == amountsB.length, "Length of tokens and token amounts not equal (B).");
        bytes32 key = keccak256(abi.encodePacked(erc20sA, amountsA, erc20sB, amountsB, msg.sender, B));

        exchangeData[msg.sender][B] = ExchangeMetaData(
            erc20sA,
            amountsA,
            NFTA,
            idA,
            erc20sB,
            amountsB,
            NFTB,
            idB,
            msg.sender,
            B,
            true,
            false,
            key,
            expiration
        );

        return key;



    }

    function cancelExchange(address B) public {
        ExchangeMetaData storage data = exchangeData[msg.sender][B];
        require(msg.sender == data.A, "Not authorized to cancel (Not A).");
        data.isAgreedByA = false;
    }

    function completeExchange(address A, bytes32 key) public {
        ExchangeMetaData storage data = exchangeData[A][msg.sender];
        require(data.isComplete == false, "Transaction already completed.");
        require(key == data.key, "Transaction is different from the proposed.");
        require(data.B == msg.sender, "Only party B of the transaction can complete the exchange.");
        require(data.isAgreedByA, "Transaction has been nullified by A.");
        require(block.timestamp < data.expiration, "Passed transaction time.");

        // Checks complete. Exchange tokens.
        // move A to B

        // ERC20
        for(uint i = 0; i < data.erc20sA.length; i ++) {
            data.erc20sA[i].transferFrom( A, msg.sender, data.amountsA[i]);

        }

        // NFT
        for(uint i = 0; i < data.NFTA.length; i ++) {
            for (uint j = 0; j < data.idA.length; j ++){
                if (data.idA[i][j] == 9999999999){
                    break;
                }         


                data.NFTA[i].transferFrom(A, msg.sender, data.idA[i][j]);
            }
        }
        

        // move B to A
        for(uint i = 0; i < data.erc20sB.length; i ++) {
            data.erc20sB[i].transferFrom( msg.sender, A, data.amountsB[i]);
            
        }

        // NFT  
        for(uint i = 0; i < data.NFTB.length; i ++) {
            for (uint j = 0; j < data.idB.length; j ++){
                if (data.idB[i][j] == 9999999999){
                    break;
                }         


                data.NFTB[i].transferFrom(msg.sender, A, data.idB[i][j]);
            }
        }
        // nullify the exchange.
        data.isComplete = true;

    }

}