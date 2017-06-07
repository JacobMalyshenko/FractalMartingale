//+------------------------------------------------------------------+
//|                                     CTradeMartingaleStrategy.mqh |
//|                                                               KZ |
//|                                             https://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "KZ"
#property link      "https://www.mql4.com"
#property version   "1.00"
#property strict

#include <CTradeStrategy.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTradeMartingaleStrategy : public CTradeStrategy
  {
private:
      CFractal* _bufferFractal;
      
      int       _martingaleGridSize;
      
protected:
      virtual  CTradeStrategyProcessingContext* GetProcessingContext(CTradeList* &tradeList);
      
               CFractal* GetSignalFractal();
               bool ShouldOpenBuy(CFractal* newFractal, CTradeList* &tradeList);
               bool ShouldOpenSell(CFractal* newFractal, CTradeList* &tradeList);
               bool ShouldCloseBuy(CTradeList* &tradeList);
               bool ShouldCloseSell(CTradeList* &tradeList);

public:
                     CTradeMartingaleStrategy(bool killSwitch, CVolumeStrategy* &volumeStrategy, int slippage, int martingaleGridSize);
                    ~CTradeMartingaleStrategy();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTradeMartingaleStrategy::CTradeMartingaleStrategy(bool killSwitch, CVolumeStrategy* &volumeStrategy, int slippage, int martingaleGridSize)
   :CTradeStrategy(killSwitch, volumeStrategy, slippage)
{
   _martingaleGridSize = martingaleGridSize;
   _systemName = "CTradeMartingaleStrategy";
   _bufferFractal = new CFractal(0, 0, 0);
   PrintFormat("%s.Constructor", _systemName);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTradeMartingaleStrategy::~CTradeMartingaleStrategy()
{
   delete(_bufferFractal);
   PrintFormat("%s.Destructor", _systemName);
}
//+------------------------------------------------------------------+

CFractal* CTradeMartingaleStrategy::GetSignalFractal(void)
{
   //if we still on the same bar as previous fractal
   if(Bars > 3 && Time[3] == _bufferFractal.GetTime()) return NULL;
   
   CFractal* newFractal = NULL;
   
   //check if there is a fractal in the resent history
   double frUp=iFractals(_Symbol, _Period, MODE_UPPER, 3);
   double frDown=iFractals(_Symbol, _Period, MODE_LOWER, 3);
   
   //check if there is a new fractal
   if(frUp > 0)
   {
      newFractal = new CFractal(Time[3], frUp, 1);
   }
   else if(frDown > 0)
   {
      newFractal = new CFractal(Time[3], frDown, -1);
   }
   //if there is no new fractal - exit
   if(newFractal != NULL)
   {
      delete(_bufferFractal);
      _bufferFractal = newFractal;
   }
   return newFractal;
}

bool CTradeMartingaleStrategy::ShouldOpenBuy(CFractal *newFractal,CTradeList *&tradeList)
{
   CTrade* trade = tradeList.GetLastBuyTrade();
   bool shouldOpenBuy = (tradeList.GetBuyCount() > 0
         && tradeList.GetBuyProfit() < 0
         && IsFractalAlignWithTrade(newFractal, trade)
         && NormalizeDouble(trade.GetOpenPrice()- _martingaleGridSize*Point, Digits) > Ask);
         
   if(shouldOpenBuy){
      PrintFormat("%s => shouldOpenBuy: %i;", _systemName, shouldOpenBuy);
      Print("Current Fractal:");
      newFractal.Print();
      Print("Last open BUY trade:");
      trade.Print();
   }
   return shouldOpenBuy;
}

bool CTradeMartingaleStrategy::ShouldOpenSell(CFractal *newFractal,CTradeList *&tradeList)
{
   CTrade* trade = tradeList.GetLastSellTrade();
   bool shouldOpenSell = (tradeList.GetSellCount() > 0
         && tradeList.GetSellProfit() < 0
         && IsFractalAlignWithTrade(newFractal, trade)
         && NormalizeDouble(trade.GetOpenPrice()+ _martingaleGridSize*Point, Digits)  < Bid);
         
   if(shouldOpenSell){
      PrintFormat("%s => shouldOpenSell: %i;", _systemName, shouldOpenSell);
      Print("Current Fractal:");
      newFractal.Print();
      Print("Last open SELL trade:");
      trade.Print();
   }
   return shouldOpenSell;
}

bool CTradeMartingaleStrategy::ShouldCloseBuy(CTradeList* &tradeList)
{
   bool shouldCloseBuy = (tradeList.GetBuyCount() > 1
         && tradeList.GetBuyProfit() > 0
         && NormalizeDouble(tradeList.GetBuyAP(), Digits) < Low[1]
         && Low[1] > Ask);
         
   if(tradeList.GetBuyCount() > 1 && tradeList.GetBuyProfit() > 0)
   {
      PrintFormat("%s => shouldCloseBuy: buyCount:%i;Profit:%f;ap:%f;Low1:%f;Ask:%f",
         _systemName,
         tradeList.GetBuyCount(), 
         tradeList.GetBuyProfit(), 
         NormalizeDouble(tradeList.GetBuyAP(), Digits),
         Low[1],
         Ask);
   }

   if(shouldCloseBuy){
      PrintFormat("%s => shouldCloseBuy: %i;", _systemName, shouldCloseBuy);
      PrintFormat("Prev Low:%f; Current Ask:%f", Low[1], Ask);
   }
   
   return shouldCloseBuy;
}

bool CTradeMartingaleStrategy::ShouldCloseSell(CTradeList* &tradeList)
{
   double Spread = MarketInfo(_Symbol, MODE_SPREAD) * Point;
   
   bool shouldCloseSell = (tradeList.GetSellCount() > 1
         && tradeList.GetSellProfit() > 0
         && NormalizeDouble(tradeList.GetSellAP() - Spread, Digits) > High[1]
         && High[1] < Bid);
         
   if(tradeList.GetSellCount() > 1 && tradeList.GetSellProfit() > 0)
   {
      PrintFormat("%s => shouldCloseSell: sellCount:%i;Profit:%f;ap:%f;High1:%f;Bid:%f",
         _systemName,
         tradeList.GetSellCount(), 
         tradeList.GetSellProfit(), 
         NormalizeDouble(tradeList.GetSellAP() - Spread, Digits),
         High[1],
         Bid);
   }

   if(shouldCloseSell){
      PrintFormat("%s => shouldCloseSell: %i;", _systemName, shouldCloseSell);
      PrintFormat("Prev High:%f; Current Bid:%f", High[1], Bid);
   }
   
   return shouldCloseSell;
}

CTradeStrategyProcessingContext* CTradeMartingaleStrategy::GetProcessingContext(CTradeList* &tradeList)
{
   bool shouldOpenBuy = false;
   bool shouldOpenSell = false;
   bool shouldCloseBuy = false;
   bool shouldCloseSell = false;
   
   CFractal* newFractal = GetSignalFractal();
   
   if(newFractal != NULL)
   {
      shouldOpenBuy = ShouldOpenBuy(newFractal, tradeList);
      shouldOpenSell = ShouldOpenSell(newFractal, tradeList);
   }
   
   shouldCloseBuy = ShouldCloseBuy(tradeList);
   shouldCloseSell = ShouldCloseSell(tradeList);
   
   if(!(shouldOpenBuy || shouldOpenSell || shouldCloseBuy || shouldCloseSell)) return NULL;
   
   PrintFormat("%s => tradeList: GetBuyProfit:%f; GetSellProfit:%f", _systemName, tradeList.GetBuyProfit(), tradeList.GetSellProfit());
   PrintFormat("%s => shouldOpenB:%i; shouldOpenS:%i; shouldCloseB:%i; shouldCloseS:%i", 
   _systemName, shouldOpenBuy, shouldOpenSell, shouldCloseBuy, shouldCloseSell);
   
   return new CTradeStrategyProcessingContext(newFractal,
      shouldOpenBuy, shouldOpenSell, shouldCloseBuy, shouldCloseSell);
}

