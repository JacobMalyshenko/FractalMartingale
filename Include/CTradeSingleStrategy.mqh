//+------------------------------------------------------------------+
//|                                         CTradeSingleStrategy.mqh |
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
class CTradeSingleStrategy : public CTradeStrategy
  {
private:
      CFractal* _bufferFractal;
protected:
      virtual  CTradeStrategyProcessingContext* GetProcessingContext(CTradeList* &tradeList);
      
               CFractal* GetSignalFractal();
public:
                     CTradeSingleStrategy(bool killSwitch, CVolumeStrategy* &volumeStrategy, int slippage);
                    ~CTradeSingleStrategy();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTradeSingleStrategy::CTradeSingleStrategy(bool killSwitch, CVolumeStrategy* &volumeStrategy, int slippage)
   :CTradeStrategy(killSwitch, volumeStrategy, slippage)
{
   _systemName = "CTradeSingleStrategy";
   _bufferFractal = new CFractal(0, 0, 0);
   PrintFormat("%s.Constructor", _systemName);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTradeSingleStrategy::~CTradeSingleStrategy()
{
   delete(_bufferFractal);
   PrintFormat("%s.Destructor", _systemName);
}
//+------------------------------------------------------------------+

CFractal* CTradeSingleStrategy::GetSignalFractal()
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

CTradeStrategyProcessingContext* CTradeSingleStrategy::GetProcessingContext(CTradeList* &tradeList)
{
   bool shouldOpenBuy = false;
   bool shouldOpenSell = false;
   
   CFractal* newFractal = GetSignalFractal();
   
   int buyTradeCount = tradeList.GetBuyCount();
   int sellTradeCount = tradeList.GetSellCount();

   if(newFractal != NULL)
   {
      shouldOpenBuy = (buyTradeCount == 0 && newFractal.GetDirection() < 0 && Bid > High[1]);
      shouldOpenSell = (sellTradeCount == 0 && newFractal.GetDirection() > 0 && Ask < Low[1]);

//      shouldOpenBuy = (buyTradeCount == 0 && newFractal.GetDirection() < 0);
//      shouldOpenSell = (sellTradeCount == 0 && newFractal.GetDirection() > 0);
// update

   }
   
   bool shouldCloseBuy = ((buyTradeCount == 1) 
         && tradeList.GetBuyProfit() > 0 
         && NormalizeDouble(tradeList.GetBuyAP(), Digits) < Low[1]
         && Low[1] > Ask);

   if(shouldCloseBuy){
      PrintFormat("%s => shouldCloseBuy: %i;", _systemName, shouldCloseBuy);
      PrintFormat("Prev Low:%f; Current Ask:%f", Low[1], Ask);
   }
   
   double Spread = MarketInfo(_Symbol, MODE_SPREAD) * Point;
   
   bool shouldCloseSell = ((sellTradeCount == 1) 
         && tradeList.GetSellProfit() > 0 
         && NormalizeDouble(tradeList.GetSellAP() - Spread, Digits) > High[1]
         && High[1] < Bid);
         
   if(shouldCloseSell){
      PrintFormat("%s => shouldCloseSell: %i;", _systemName, shouldCloseSell);
      PrintFormat("Prev High:%f; Current Bid:%f", High[1], Bid);
   }
   
   if(!(shouldOpenBuy || shouldOpenSell || shouldCloseBuy || shouldCloseSell)) return NULL;
   
   PrintFormat("%s => tradeList: GetBuyProfit:%f; GetSellProfit:%f", _systemName, tradeList.GetBuyProfit(), tradeList.GetSellProfit());
   PrintFormat("%s => shouldOpenBuy: %i; shouldOpenSell: %i; shouldCloseBuy: %i; shouldCloseSell: %i", _systemName, shouldOpenBuy, shouldOpenSell, shouldCloseBuy, shouldCloseSell);
   
   return new CTradeStrategyProcessingContext(newFractal,
      shouldOpenBuy, shouldOpenSell, shouldCloseBuy, shouldCloseSell);
}
