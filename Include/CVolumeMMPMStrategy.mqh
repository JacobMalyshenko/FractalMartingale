//+------------------------------------------------------------------+
//|                                          CVolumeMMPMStrategy.mqh |
//|                                                               KZ |
//|                                             https://www.mql4.com |
//| This VolumeStrategy is an enhanced version of MM strategy.       |
//| The difference is it adds additional koefficient derived from    |
//| Martingale grid size. Thus the name change PlusMartingale.       |
//|                                                                  |
//| Calculation rule:                                                |
//|   NewVolume = SV * (AB/DM) * MM * (|CP - OAP| / MGS)             |
//|                                                                  |
//| Where: SV - Start Volume; Adviser property.                      |
//|        AB - current Account Balance                              |
//|        DM - Dollar Multiplier; Adviser property.                 |
//|        MM - Martingale Multiplicator; Adviser property.          |
//|        CP - Current Price (Bid or Ask)                           |
//|        OAP - Opposite trade Average Price - break even           |
//|        MGS - Martingale Grid Size; Adviser property.             |
//+------------------------------------------------------------------+
#property copyright "KZ"
#property link      "https://www.mql4.com"
#property version   "1.00"
#property strict

#include <CVolumeMMStrategy.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CVolumeMMPMStrategy : public CVolumeMMStrategy
  {
protected:
      double _martingaleMultiplicator;
      double _maxBaseVolume;
      int _martingaleGridSize;
      
public:
                     CVolumeMMPMStrategy(bool killSwitch, double baseVolume, double dollarMultiplier, 
                                          double maxBaseVolume, double martingaleMultiplicator, int martingaleGridSize);
                    ~CVolumeMMPMStrategy();
                    
                     virtual double GetNewVolume(string bs, CTradeList *&tradeList);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CVolumeMMPMStrategy::CVolumeMMPMStrategy(bool killSwitch, double baseVolume, double dollarMultiplier, 
                                          double maxBaseVolume, double martingaleMultiplicator, int martingaleGridSize)
                       : CVolumeMMStrategy(killSwitch, baseVolume, dollarMultiplier)
{
   _martingaleMultiplicator = martingaleMultiplicator;
   _maxBaseVolume = maxBaseVolume;
   _martingaleGridSize = martingaleGridSize;
   Print("CVolumeMMPMStrategy.Constructor");
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CVolumeMMPMStrategy::~CVolumeMMPMStrategy()
{
   Print("CVolumeMMPMStrategy.Destructor");
}
//+------------------------------------------------------------------+

double CVolumeMMPMStrategy::GetNewVolume(string bs, CTradeList *&tradeList)
{
   if(_killSwitch) return _volume;
   
   double multiplicator = 0;
   
   if(bs == "B" && tradeList.GetSellCount() > 1){
   
      multiplicator =  _martingaleMultiplicator * (Ask - tradeList.GetSellAP()) / (_martingaleGridSize*Point);
      
      PrintFormat("CVolumeMMPMStrategy.GetNewVolume [%s]: ask:%f;SellAp:%f;ZoneSize:%f;divider:%f;multiplicator:%f", 
         bs, 
         Ask, 
         tradeList.GetSellAP(), 
         (Ask - tradeList.GetSellAP()),
         _martingaleGridSize*Point,
         multiplicator);
   }
   else if(bs == "S" && tradeList.GetBuyCount() > 1){
   
      multiplicator = _martingaleMultiplicator * (tradeList.GetBuyAP() - Bid) / (_martingaleGridSize*Point);
      
      PrintFormat("CVolumeMMPMStrategy.GetNewVolume [%s]: bid:%f;BuyAp:%f;ZoneSize:%f;divider:%f;multiplicator:%f", 
         bs, 
         Bid, 
         tradeList.GetBuyAP(), 
         (tradeList.GetBuyAP() - Bid), 
         _martingaleGridSize*Point, 
         multiplicator);
   }
   
   double volume = _volume * floor(AccountBalance()/ _dollarMultiplier) * MathMax(multiplicator, 1);
   
   double minLot = MarketInfo(Symbol(), MODE_MINLOT);
   double maxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   
   return MathMax(MathMin(MathMin(volume, _maxBaseVolume), maxLot), minLot);
}