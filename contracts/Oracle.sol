// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract Oracle {
    uint public precipitation = 16; // flood

    function getPrecipitation(string memory) external view returns(uint) {
        return precipitation;
    }

    function setPrecipitation(uint256 _precipitation) external {
        precipitation = _precipitation;
    }
}