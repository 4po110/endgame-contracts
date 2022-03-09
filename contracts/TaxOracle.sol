// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract EndGameTaxOracle is Ownable {
    using SafeMath for uint256;

    IERC20 public endgame;
    IERC20 public wftm;
    address public pair;

    constructor(
        address _endgame,
        address _wftm,
        address _pair
    ) public {
        require(_endgame != address(0), "endgame address cannot be 0");
        require(_wftm != address(0), "wftm address cannot be 0");
        require(_pair != address(0), "pair address cannot be 0");
        endgame = IERC20(_endgame);
        wftm = IERC20(_wftm);
        pair = _pair;
    }

    function consult(address _token, uint256 _amountIn) external view returns (uint144 amountOut) {
        require(_token == address(endgame), "token needs to be endgame");
        uint256 endgameBalance = endgame.balanceOf(pair);
        uint256 wftmBalance = wftm.balanceOf(pair);
        return uint144(endgameBalance.div(wftmBalance));
    }

    function setEndGame(address _endgame) external onlyOwner {
        require(_endgame != address(0), "endgame address cannot be 0");
        endgame = IERC20(_endgame);
    }

    function setWftm(address _wftm) external onlyOwner {
        require(_wftm != address(0), "wftm address cannot be 0");
        wftm = IERC20(_wftm);
    }

    function setPair(address _pair) external onlyOwner {
        require(_pair != address(0), "pair address cannot be 0");
        pair = _pair;
    }



}
