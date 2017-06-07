//+------------------------------------------------------------------+
//|                                              CVolumeStrategy.mqh |
//|                                                               KZ |
//|                                             https://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "KZ"
#property link      "https://www.mql4.com"
#property version   "1.00"
#property strict

#include <ETradeStatus.mqh>
#include <CTradeList.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CVolumeStrategy
  {
protected:
      double   _volume;
      bool     _killSwitch;

public:
                     CVolumeStrategy(bool killSwitch, double volume);
                    ~CVolumeStrategy();
                    
                    virtual double GetNewVolume(string bs, CTradeList *&tradeList);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CVolumeStrategy::CVolumeStrategy(bool killSwitch, double volume)
{
   _volume = volume;
   _killSwitch = killSwitch;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CVolumeStrategy::~CVolumeStrategy()
  {
  }
//+------------------------------------------------------------------+

double CVolumeStrategy::GetNewVolume(string bs, CTradeList *&tradeList)
{
   return _volume;
}