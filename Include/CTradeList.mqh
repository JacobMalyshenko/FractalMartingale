//+------------------------------------------------------------------+
//|                                                   CTradeList.mqh |
//|                                                               KZ |
//|                                             https://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "KZ"
#property link      "https://www.mql4.com"
#property version   "1.00"
#property strict

#include <ETradeStatus.mqh>
#include <CTrade.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTradeList
  {
private:
   CTrade*           _trades[];
   CTrade*           _buyTrades[];
   CTrade*           _sellTrades[];
   
   CTrade*           _lastTrade;
   CTrade*           _lastBuyTrade;
   CTrade*           _lastSellTrade;
   CTrade*           _secondLastTrade;
   CTrade*           _secondLastBuyTrade;
   CTrade*           _secondLastSellTrade;
   
   int               _tradeCount;
   int               _buyTradeCount;
   int               _sellTradeCount;
   
   double            _profit;
   double            _buyProfit;
   double            _sellProfit;
   
   double            _volume;
   double            _buyVolume;
   double            _sellVolume;
   
   double            _sellAP;
   double            _buyAP;
public:
                     CTradeList();
                    ~CTradeList();
                    
                    void Clear();
                    void Add(CTrade* &newTrade);
                    CTrade* GetTrade(int index) {return _trades[index];}
                    CTrade* GetBuyTrade(int index) {return _buyTrades[index];}
                    CTrade* GetSellTrade(int index) {return _sellTrades[index];}
                    
                    int GetCount() {return _tradeCount;}
                    int GetBuyCount() {return _buyTradeCount;}
                    int GetSellCount() {return _sellTradeCount;}
                    
                    CTrade* GetLastTrade() {return _lastTrade;}
                    CTrade* GetLastBuyTrade() {return _lastBuyTrade;}
                    CTrade* GetLastSellTrade() {return _lastSellTrade;}
                    
                    CTrade* GetSecondLastTrade() {return _secondLastTrade;}
                    CTrade* GetSecondLastBuyTrade() {return _secondLastBuyTrade;}
                    CTrade* GetSecondLastSellTrade() {return _secondLastSellTrade;}
                    
                    double GetProfit() {return _profit;}
                    double GetBuyProfit() {return _buyProfit;}
                    double GetSellProfit() {return _sellProfit;}
                    
                    double GetVolume() {return _volume;}
                    double GetBuyVolume() {return _buyVolume;}
                    double GetSellVolume() {return _sellVolume;}
                    
                    double GetBuyAP() {return _buyAP;}
                    double GetSellAP() {return _sellAP;}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTradeList::CTradeList()
{
   _tradeCount = _buyTradeCount = _sellTradeCount = 0;
   _lastTrade = _lastBuyTrade = _lastSellTrade = NULL;
   _secondLastTrade = _secondLastBuyTrade = _secondLastSellTrade = NULL;
   
   _profit = _buyProfit = _sellProfit = 0;
   _volume = _buyVolume = _sellVolume = 0;
   _buyAP = _sellAP = 0;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTradeList::~CTradeList()
{
   Clear();
}
//+------------------------------------------------------------------+

void CTradeList::Clear()
{
   for(int i = 0; i < _tradeCount; i++)
   {
      delete(_trades[i]);
   }
   ArrayResize(_trades, 0);
   ArrayResize(_buyTrades, 0);
   ArrayResize(_sellTrades, 0);
   
   _tradeCount = _buyTradeCount = _sellTradeCount = 0;
   _lastTrade = _lastBuyTrade = _lastSellTrade = NULL;
   _secondLastTrade = _secondLastBuyTrade = _secondLastSellTrade = NULL;
   
   _profit = _buyProfit = _sellProfit = 0;
   _volume = _buyVolume = _sellVolume = 0;
   _buyAP = _sellAP = 0;
}

void CTradeList::Add(CTrade* &newTrade)
{
   _tradeCount++;
   ArrayResize(_trades, _tradeCount);
   _trades[_tradeCount-1] = newTrade;
   _secondLastTrade = _lastTrade;
   _lastTrade = newTrade;
   
   double profit = newTrade.GetCurrentProfit();
   double volume = newTrade.GetVolume();
   
   double openPrice = newTrade.GetOpenPrice();
   
   _profit += profit;
   
   switch(newTrade.GetOrderType())
   {
      case OP_BUY:
         _buyAP *= _buyVolume;
         _buyTradeCount++;
         ArrayResize(_buyTrades, _buyTradeCount);
         _buyTrades[_buyTradeCount-1] = newTrade;
         _secondLastBuyTrade = _lastBuyTrade;
         _lastBuyTrade = newTrade;
         _buyProfit += profit;
         _buyVolume += volume;
         _buyAP += volume * (openPrice != 0 ? openPrice : Ask);
         _buyAP /= _buyVolume;
         break;
      case OP_SELL:
         _sellAP *= _sellVolume;
         _sellTradeCount++;
         ArrayResize(_sellTrades, _sellTradeCount);
         _sellTrades[_sellTradeCount-1] = newTrade;
         _secondLastSellTrade = _lastSellTrade;
         _lastSellTrade = newTrade;
         _sellProfit += profit;
         _sellVolume += volume;
         _sellAP += volume * (openPrice != 0 ? openPrice : Bid);
         _sellAP /= _sellVolume;
         break;
   }
   _volume = _buyVolume - _sellVolume;
}