# Open-NFT-swap


exchangeData(A, B):
    Returns the detailed transaction data. 
    
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
    A: transaction initiator.
    B: transaction finisher. 

initializeExchange(
        ERC20[] memory erc20sA, uint[] memory amountsA, 
        ERC721[] memory NFTA, uint[][] memory idA,
        ERC20[] memory erc20sB, uint[] memory amountsB, 
        ERC721[] memory NFTB, uint[][] memory idB, address B, uint expiration):

    Initialize an exchange, by specifying whom the message sender wants to transact with.
    erc20sA: An array of addresses of the erc20's that A wants to give B.
    amountsA: An array of the amount of erc20's that A wants to give B, respectively. 
    NFTA: An array of addresses of the NFTs that A wants to give B.
    idA: An array of arrays of the ids of the NFTs that A wants to give B. (2D array. Row: NFT, columns: NFT ids. Extra spaces MUST be padded by "9999999999")

    ...B: from B to A.
    Address B: the finisher of the transaction. B needs to call completeExchange to finish the transaction. 
    Expiration: the time when the transaction would expire. 

cancelExchange(address B):
    Can only be called by A. Cancels the transaction. 
    B: The address of entity B. 

completeExchange(address A, bytes32 key):
    Exchanges tokens between A and B as specified. Only B can call this function. 
    A: The initiator of the transaction. 
    key: the hashed key of the transaction, has to match that of the transaction specified. Can be accessed through exchangeData(A, B).key

