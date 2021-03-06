//+------------------------------------------------------------------+
//|                                     CTradeNoLossDrawStrategy.mqh |
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
class CTradeNoLossDrawStrategy : public CTradeStrategy
  {
private:
   double _breakEvenBuyPrice;
   double _breakEvenSellPrice;

                     double CalcBreakEvenBuyPrice(CTradeList* &tradeList);
                     double CalcBreakEvenSellPrice(CTradeList* &tradeList);
public:
                     CTradeNoLossDrawStrategy(bool killSwitch);
                    ~CTradeNoLossDrawStrategy();
                    
                     virtual void Process(CTradeList* &tradeList);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTradeNoLossDrawStrategy::CTradeNoLossDrawStrategy(bool killSwitch)
   :CTradeStrategy(killSwitch)
{
   _breakEvenBuyPrice = _breakEvenSellPrice = 0;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTradeNoLossDrawStrategy::~CTradeNoLossDrawStrategy()
{
}
//+------------------------------------------------------------------+

void CTradeNoLossDrawStrategy::Process(CTradeList* &tradeList)
{
   if(_killSwitch) return;
   
   double breakEvenPrice = CalcBreakEvenBuyPrice(tradeList);
   
   if(_breakEvenBuyPrice != breakEvenPrice)
   {
      _breakEvenBuyPrice = breakEvenPrice;
      
      if(ObjectFind("NoLossBuyLINE") < 0)
      {
         ObjectCreate("NoLossBuyLINE", OBJ_HLINE, 0, Time[0], breakEvenPrice);
      }
      else
      {
         ObjectMove("NoLossBuyLINE", 0, Time[0], breakEvenPrice);
      }
      PrintFormat("Break Even Buy Price: [%f]", _breakEvenBuyPrice);
   }
   if(tradeList.GetBuyProfit() > 0)
   {
      ObjectSet("NoLossBuyLINE", OBJPROP_COLOR, clrAqua);
   }
   else
   {
      ObjectSet("NoLossBuyLINE", OBJPROP_COLOR, clrDarkOrchid);
   }
   
   breakEvenPrice = CalcBreakEvenSellPrice(tradeList);
   
   if(_breakEvenSellPrice != breakEvenPrice)
   {
      _breakEvenSellPrice = breakEvenPrice;
      
      if(ObjectFind("NoLossSellLINE") < 0)
      {
         ObjectCreate("NoLossSellLINE", OBJ_HLINE, 0, Time[0], breakEvenPrice);
      }
      else
      {
         ObjectMove("NoLossSellLINE", 0, Time[0], breakEvenPrice);
      }
      PrintFormat("Break Even Sell Price: [%f]", _breakEvenSellPrice);
   }
   if(tradeList.GetSellProfit() > 0)
   {
      ObjectSet("NoLossSellLINE", OBJPROP_COLOR, clrOrange);
   }
   else
   {
      ObjectSet("NoLossSellLINE", OBJPROP_COLOR, clrCrimson);
   }
}

double CTradeNoLossDrawStrategy::CalcBreakEvenSellPrice(CTradeList* &tradeList)
{
   double Spread = MarketInfo(_Symbol, MODE_SPREAD) * Point;
   
   return NormalizeDouble(tradeList.GetSellAP() - Spread, Digits);
}

double CTradeNoLossDrawStrategy::CalcBreakEvenBuyPrice(CTradeList* &tradeList)
{
   return NormalizeDouble(tradeList.GetBuyAP(), Digits);
}