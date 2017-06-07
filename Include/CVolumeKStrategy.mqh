//+------------------------------------------------------------------+
//|                                             CVolumeKStrategy.mqh |
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
class CVolumeKStrategy : public CVolumeStrategy
  {
private:
      double _multiplicator;
public:
                     CVolumeKStrategy(bool killSwitch, double baseVolume, double multiplicator);
                    ~CVolumeKStrategy();
                    
                     double GetMultiplicator(){return _multiplicator;}
                    
                     virtual double GetNewVolume(string bs, CTradeList *&tradeList);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CVolumeKStrategy::CVolumeKStrategy(bool killSwitch, double baseVolume, double multiplicator): CVolumeStrategy(killSwitch, baseVolume)
{
   _multiplicator = multiplicator;
   Print("CVolumeKStrategy.Constructor");
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CVolumeKStrategy::~CVolumeKStrategy()
{
   Print("CVolumeKStrategy.Destructor");
}
//+------------------------------------------------------------------+

double CVolumeKStrategy::GetNewVolume(string bs, CTradeList *&tradeList)
{
   if(_killSwitch) return _volume;
   
   CTrade* trade = (bs == "B") ? tradeList.GetLastBuyTrade() : tradeList.GetLastSellTrade();
   
   if(trade == NULL) return _volume;
   
   double prevVolume = trade.GetVolume();
   
   double newVolume = prevVolume * _multiplicator;
   
   double volumeStep = MarketInfo(Symbol(), MODE_LOTSTEP);
   
   newVolume -= MathMod(newVolume, volumeStep);
   
   return MathMax(newVolume, prevVolume + volumeStep);
}