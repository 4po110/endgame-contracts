// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "./owner/Operator.sol";
import "./interfaces/ITaxable.sol";
import "./interfaces/IUniswapV2Router.sol";
import "./interfaces/IERC20.sol";

contract TaxOfficeV2 is Operator {
    using SafeMath for uint256;

    address public endgame = address(0x6c021Ae822BEa943b2E66552bDe1D2696a53fbB7);
    address public wftm = address(0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83);
    address public uniRouter = address(0xF491e7B69E4244ad4002BC14e878a34207E38c29);

    mapping(address => bool) public taxExclusionEnabled;

    function setTaxTiersTwap(uint8 _index, uint256 _value) public onlyOperator returns (bool) {
        return ITaxable(endgame).setTaxTiersTwap(_index, _value);
    }

    function setTaxTiersRate(uint8 _index, uint256 _value) public onlyOperator returns (bool) {
        return ITaxable(endgame).setTaxTiersRate(_index, _value);
    }

    function enableAutoCalculateTax() public onlyOperator {
        ITaxable(endgame).enableAutoCalculateTax();
    }

    function disableAutoCalculateTax() public onlyOperator {
        ITaxable(endgame).disableAutoCalculateTax();
    }

    function setTaxRate(uint256 _taxRate) public onlyOperator {
        ITaxable(endgame).setTaxRate(_taxRate);
    }

    function setBurnThreshold(uint256 _burnThreshold) public onlyOperator {
        ITaxable(endgame).setBurnThreshold(_burnThreshold);
    }

    function setTaxCollectorAddress(address _taxCollectorAddress) public onlyOperator {
        ITaxable(endgame).setTaxCollectorAddress(_taxCollectorAddress);
    }

    function excludeAddressFromTax(address _address) external onlyOperator returns (bool) {
        return _excludeAddressFromTax(_address);
    }

    function _excludeAddressFromTax(address _address) private returns (bool) {
        if (!ITaxable(endgame).isAddressExcluded(_address)) {
            return ITaxable(endgame).excludeAddress(_address);
        }
    }

    function includeAddressInTax(address _address) external onlyOperator returns (bool) {
        return _includeAddressInTax(_address);
    }

    function _includeAddressInTax(address _address) private returns (bool) {
        if (ITaxable(endgame).isAddressExcluded(_address)) {
            return ITaxable(endgame).includeAddress(_address);
        }
    }

    function taxRate() external view returns (uint256) {
        return ITaxable(endgame).taxRate();
    }

    function addLiquidityTaxFree(
        address token,
        uint256 amtEndGame,
        uint256 amtToken,
        uint256 amtEndGameMin,
        uint256 amtTokenMin
    )
        external
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        require(amtEndGame != 0 && amtToken != 0, "amounts can't be 0");
        _excludeAddressFromTax(msg.sender);

        IERC20(endgame).transferFrom(msg.sender, address(this), amtEndGame);
        IERC20(token).transferFrom(msg.sender, address(this), amtToken);
        _approveTokenIfNeeded(endgame, uniRouter);
        _approveTokenIfNeeded(token, uniRouter);

        _includeAddressInTax(msg.sender);

        uint256 resultAmtEndGame;
        uint256 resultAmtToken;
        uint256 liquidity;
        (resultAmtEndGame, resultAmtToken, liquidity) = IUniswapV2Router(uniRouter).addLiquidity(
            endgame,
            token,
            amtEndGame,
            amtToken,
            amtEndGameMin,
            amtTokenMin,
            msg.sender,
            block.timestamp
        );

        if(amtEndGame.sub(resultAmtEndGame) > 0) {
            IERC20(endgame).transfer(msg.sender, amtEndGame.sub(resultAmtEndGame));
        }
        if(amtToken.sub(resultAmtToken) > 0) {
            IERC20(token).transfer(msg.sender, amtToken.sub(resultAmtToken));
        }
        return (resultAmtEndGame, resultAmtToken, liquidity);
    }

    function addLiquidityETHTaxFree(
        uint256 amtEndGame,
        uint256 amtEndGameMin,
        uint256 amtFtmMin
    )
        external
        payable
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        require(amtEndGame != 0 && msg.value != 0, "amounts can't be 0");
        _excludeAddressFromTax(msg.sender);

        IERC20(endgame).transferFrom(msg.sender, address(this), amtEndGame);
        _approveTokenIfNeeded(endgame, uniRouter);

        _includeAddressInTax(msg.sender);

        uint256 resultAmtEndGame;
        uint256 resultAmtFtm;
        uint256 liquidity;
        (resultAmtEndGame, resultAmtFtm, liquidity) = IUniswapV2Router(uniRouter).addLiquidityETH{value: msg.value}(
            endgame,
            amtEndGame,
            amtEndGameMin,
            amtFtmMin,
            msg.sender,
            block.timestamp
        );

        if(amtEndGame.sub(resultAmtEndGame) > 0) {
            IERC20(endgame).transfer(msg.sender, amtEndGame.sub(resultAmtEndGame));
        }
        return (resultAmtEndGame, resultAmtFtm, liquidity);
    }

    function setTaxableEndGameOracle(address _endgameOracle) external onlyOperator {
        ITaxable(endgame).setEndGameOracle(_endgameOracle);
    }

    function transferTaxOffice(address _newTaxOffice) external onlyOperator {
        ITaxable(endgame).setTaxOffice(_newTaxOffice);
    }

    function taxFreeTransferFrom(
        address _sender,
        address _recipient,
        uint256 _amt
    ) external {
        require(taxExclusionEnabled[msg.sender], "Address not approved for tax free transfers");
        _excludeAddressFromTax(_sender);
        IERC20(endgame).transferFrom(_sender, _recipient, _amt);
        _includeAddressInTax(_sender);
    }

    function setTaxExclusionForAddress(address _address, bool _excluded) external onlyOperator {
        taxExclusionEnabled[_address] = _excluded;
    }

    function _approveTokenIfNeeded(address _token, address _router) private {
        if (IERC20(_token).allowance(address(this), _router) == 0) {
            IERC20(_token).approve(_router, type(uint256).max);
        }
    }
}
