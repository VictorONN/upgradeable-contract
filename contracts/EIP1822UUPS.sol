//SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

contract Proxy {
    constructor(bytes memory constructData, address contractLogic) {
        //Code position in storage is keccak256(PROXIABLE) = ""
        assembly {
            sstore()
        }
        (bool success, bytes memory result) =
            contractLogic.delegatecall(constructData); // solium-disable-line
        require(success, "Construction true");
    }

    fallback() external payable {
        assembly {
            // solium-disable-line
            let contractLogic := sload()
            calldatacopy(0x0, 0x0, calldatasize())
            let success := delegatecall(
                sub(gas(), 10000),
                contractLogic,
                0x0,
                calldatasize(),
                0,
                0
            )
            let retSz := returndatasize()
            returndatacopy(0, 0, retSz)
            switch success
                case 0 {
                    revert(0, retSz)
                }
                default {
                    return(0, retSz)
                }
        }
    }
}

contract Proxiable {
    // Code position in storage is keccak256("PROXIABLE) = "0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7"

    function updateCodeAddress(address newAddress) internal {
        require(
            bytes32(
                0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7
            ) == Proxiable(newAddress).proxiableUUID(),
            "Not compatible"
        );
        assembly {
            //solium-disable-line
            sstore(
                0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7,
                newAddress
            )
        }
    }

    function proxiableUUID() public pure returns (bytes32) {
        return
            0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7;
    }
}

contract MyContract {
    address public owner;
    uint256 public myUint;

    function constructor1() public {
        require(owner == address(0), "Already initialized");
        owner = msg.sender;
    }

    function increment() public {
        //require(msg.sender == owner, "Only the owner can increment"); //someone forgot to uncomment
        myUint++;
    }
}

contract MyFinalContract is MyContract, Proxiable {
    function updateCode(address newCode) public onlyOwner {
        updateCodeAddress(newCode);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner allowed");
        _;
    }
}
