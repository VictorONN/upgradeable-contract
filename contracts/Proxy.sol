//SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

contract Proxy {
    constructor(bytes memory constructData, address contractLogic) {
        assembly {
            sstore()
        }
        (bool success, bytes memory result) =
            contractLogic.delegatecall(constructData);
    }
}
