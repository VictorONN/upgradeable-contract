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
        assembly { // solium-disable-line
        let contractLogic "= sload()  
        calldatacopy(0x0, 0x0, calldatasize())
        let success
        }
    }
}
