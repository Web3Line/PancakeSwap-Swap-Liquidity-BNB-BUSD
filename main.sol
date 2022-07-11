//SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;
import "https://github.com/pancakeswap/pancake-swap-core/blob/master/contracts/interfaces/IPancakeFactory.sol";
import "https://github.com/pancakeswap/pancake-swap-periphery/blob/master/contracts/interfaces/IPancakeRouter02.sol";
import "https://github.com/pancakeswap/pancake-swap-periphery/blob/master/contracts/interfaces/IERC20.sol";
import "https://github.com/pancakeswap/pancake-swap-core/blob/master/contracts/interfaces/IPancakePair.sol";
import "./PancakeLibrary.sol";
import "https://github.com/pancakeswap/pancake-swap-core/blob/master/contracts/interfaces/IPancakeFactory.sol";

contract pancakeswap{
    IPancakeRouter02 Prouter;
    IPancakeFactory pactory;
    address internal constant pancakeRouter = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    address private constant BUSDAddress = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    address internal constant factoryAddress = 0x6725F303b657a9451d8BA641348b6761A6CC7a17;
    constructor() public {
        Prouter = IPancakeRouter02(pancakeRouter);
        pactory = IPancakeFactory(factoryAddress);
    }
    receive() external payable{}
    fallback() external payable{}

    function swapExactBNBToBUSD() external payable {
        address [] memory path = new address[](2);
        uint deadLine = block.timestamp + 120;
        path[0] = Prouter.WETH();
        path[1] = BUSDAddress;
        Prouter.swapExactETHForTokens{value: msg.value}(1, path, msg.sender, deadLine);

    }
    function swapBNBForExactBUSD(uint amountOut) public payable{
        address [] memory path = new address[](2);
        uint deadLine = block.timestamp + 120;
        path[0] = Prouter.WETH();
        path[1] = BUSDAddress;
        Prouter.swapETHForExactTokens{value: value}(amountOut, path, msg.sender, deadLine);
    }
    function swapExactBUSDForBNB(uint amountIn) public payable{
        address [] memory path = new address[](2);
        uint deadLine = block.timestamp + 120;
        path[0] = BUSDAddress;
        path[1] = Prouter.WETH();
        IERC20(BUSDAddress).transferFrom(msg.sender, address(this), amountIn);
        IERC20(BUSDAddress).approve(pancakeRouter, amountIn);
        Prouter.swapExactTokensForETH(amountIn ,1, path, msg.sender, deadLine);
    }
    function howMuchNeedBNB(uint BUSCAmount) public view returns(uint){
        uint needBNB;
        (uint BNBNeed, uint BUSDNeed) = PancakeLibrary.getReserves(factoryAddress, Prouter.WETH(), BUSDAddress);
        needBNB = PancakeLibrary.quote(BUSCAmount, BNBNeed, BUSDNeed);
        return needBNB;
    }
    function howMuchNeedBUSD(uint BNBAmount) public view returns(uint){
        uint needBUSD;
        (uint BUSDNeed, uint BNBNeed) = PancakeLibrary.getReserves(factoryAddress, BUSDAddress, Prouter.WETH());
        needBUSD = PancakeLibrary.quote(BNBAmount, BNBNeed, BUSDNeed);
        return needBUSD;
    }
    function addLiquidityBNBToBUSD(uint BUSDAmount) external payable returns(uint) {
        uint liquidity;
        uint deadLine = block.timestamp + 120;
        address payable _to = msg.sender;
        IERC20(BUSDAddress).transferFrom(_to, address(this), BUSDAmount);
        IERC20(BUSDAddress).approve(pancakeRouter, BUSDAmount);
        (, , liquidity)= Prouter.addLiquidityETH{value: value}(BUSDAddress, BUSDAmount, 1, 1, _to, deadLine);
        usrBalance[msg.sender] = usrBalance[msg.sender] + liquidity;
        return liquidity;
    }
    mapping(address => uint) usrBalance;
    function profit() public view returns(uint) {
        uint usrProfit; 
        usrProfit = getBalance() - usrBalance[msg.sender];
        return usrProfit;
    }
    function getBalance() public view returns(uint) {
        address pair;
        pair = pactory.getPair(Prouter.WETH(), BUSDAddress);
        return IERC20(pair).balanceOf(msg.sender);
    }
    function getBalanceBUSD() public view returns(uint){
        return IERC20(BUSDAddress).balanceOf(msg.sender);
    }
    function getPairLp() public view returns(address) {
        return pactory.getPair(BUSDAddress, Prouter.WETH());
    }
    function removeLiquidityBNB(uint liquidity) external payable returns(uint, uint){
        address pair = getPairLp();
        uint deadLine = block.timestamp + 120;
        IERC20(pair).transferFrom(msg.sender, address(this), liquidity);
        IERC20(pair).approve(pancakeRouter, liquidity);
        (uint BUSDAmount, uint BNBAmount) = Prouter.removeLiquidityETH(BUSDAddress, liquidity, 1, 1, msg.sender, deadLine);
        return (BUSDAmount, BNBAmount);
    }
    uint public value;
    function setBNB() external payable returns(uint){
        value = msg.value;
        return value;
    }
}