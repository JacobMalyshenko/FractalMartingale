//+------------------------------------------------------------------+
//|                                            CVolumeMMStrategy.mqh |
//|                                                               KZ |
//|                                             https://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "KZ"
#property link      "https://www.mql4.com"
#property version   "1.00"
#property strict

#include <CVolumeStrategy.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CVolumeMMStrategy : public CVolumeStrategy
  {
protected:
      double _dollarMultiplier;
public:
                     CVolumeMMStrategy(bool killSwitch, double baseVolume, double dollarMultiplier);
                    ~CVolumeMMStrategy();
                    
                     virtual double GetNewVolume(string bs, CTradeList *&tradeList);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CVolumeMMStrategy::CVolumeMMStrategy(bool killSwitch, double baseVolume, double dollarMultiplier): CVolumeStrategy(killSwitch, baseVolume)
{
   _dollarMultiplier = dollarMultiplier > 0 ? dollarMultiplier : 1;
   Print("CVolumeMMStrategy.Constructor");
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CVolumeMMStrategy::~CVolumeMMStrategy()
  {
  Print("CVolumeMMStrategy.Destructor");
  }
//+------------------------------------------------------------------+

double CVolumeMMStrategy::GetNewVolume(string bs, CTradeList *&tradeList)
{
   if(_killSwitch) return _volume;
   
   double volume = _volume * floor(AccountBalance()/ _dollarMultiplier);
   
   double minLot = MarketInfo(Symbol(), MODE_MINLOT);
   double maxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   
   return MathMax(MathMin(volume, maxLot), minLot);
}