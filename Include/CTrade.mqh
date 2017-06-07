//+------------------------------------------------------------------+
//|                                                        Trade.mqh |
//|                                                               KZ |
//|                                             https://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "KZ"
#property link      "https://www.mql4.com"
#property version   "1.00"
#property strict

#include <ETradeStatus.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTrade
  {
protected:
   bool        _dirty;
   TradeStatus _status;
   int         _ticket;

   string      _symbol;              // symbol
   int         _orderType;
   double      _volume;              // volume
   double      _price;               // price
   int         _slippage;            // slippage
   double      _stoploss;            // stop loss
   double      _takeprofit;          // take profit
   string      _comment;
   
   double      _openPrice;           //actual price trade was open with
   datetime    _openTime;            //open time
   
   double      _currentProfit;       //current profit or loss of the trade
   

public:
   CTrade(string symbol, int orderType, double volume, double price, int slippage, double stoploss, double takeprofit, string comment);
   CTrade(int ticket, string symbol, int orderType, double volume, double openPrice, datetime openTime, double stoploss, double takeprofit, double currentProfit, string comment);
  ~CTrade();
  
   TradeStatus GetStatus(){ return(_status);}
   void        SetStatus(TradeStatus status)
                  {if( _status != status){ _status = status; _dirty = true;}}

   int         GetTicket() {return(_ticket);}
   void        SetTicket(int ticket) {_ticket = ticket;}
   
   string      GetSymbol() {return(_symbol);}
   
   int         GetOrderType() {return(_orderType);}
   void        SetOrderType(int orderType) { _orderType = orderType;}
   string      GetBuySell();
   
   double      GetVolume() {return(_volume);}
   void        SetVolume(double volume)
                  {if(_volume != volume){_volume = volume; _dirty = true;}}
   double      GetPrice() {return(_price);}
   int         GetSlippage() {return(_slippage);}
   double      GetStoploss() {return(_stoploss);}
   void        SetStoploss(double stoploss) 
                  {if(_stoploss != stoploss){_stoploss = stoploss; _dirty = true;}}
   double      GetTakeprofit() {return(_takeprofit);}
   void        SetTakeprofit(double takeprofit) 
                  {if(_takeprofit != takeprofit){_takeprofit = takeprofit; _dirty = true;}}
                  
   string      GetComment(){return _comment;}
   void        SetComment(string comment){_comment = comment;}
   
   double      GetOpenPrice() {return(_openPrice);}
   datetime    GetOpenTime() {return(_openTime);}
   
   double      GetCurrentProfit() {return _currentProfit;}
   
   bool        IsDirty() {return _dirty;}
   void        ResetDirty() {_dirty = false;}
   
   void        Print();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTrade::CTrade(string symbol, int orderType, double volume, double price, int slippage, double stoploss, double takeprofit, string comment)
{
   _status = TS_NEW;
   _ticket = -1;
   _symbol = symbol;
   _orderType = orderType;
   _volume = volume;
   _price = price;
   _slippage = slippage;
   _stoploss = stoploss;
   _takeprofit = takeprofit;
   _comment = comment;
   
   _openPrice = 0;
   _openTime = 0;
   _currentProfit = 0;
   _dirty = true;
}
  
CTrade::CTrade(int ticket, string symbol, int orderType, double volume, double openPrice, datetime openTime, double stoploss, double takeprofit, double currentProfit, string comment)
{
   _ticket = ticket;
   _status = orderType <= 1 ? TS_ACTIVE : TS_PENDING;
   _symbol = symbol;
   _orderType = orderType;
   _volume = volume;
   _price = openPrice;
   _openPrice = openPrice;
   _openTime = openTime;
   _slippage = 0;
   _stoploss = stoploss;
   _takeprofit = takeprofit;
   _currentProfit = currentProfit;
   _comment = comment;
   _dirty = false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTrade::~CTrade()
  {
  }
//+------------------------------------------------------------------+


string CTrade::GetBuySell()
{
   switch(_orderType)
   {
      case OP_BUY:
      case OP_BUYLIMIT:
      case OP_BUYSTOP:
         return("BUY");
      case OP_SELL:
      case OP_SELLLIMIT:
      case OP_SELLSTOP:
         return("SELL");
   }
   return ("");
}

void CTrade::Print()
{
   PrintFormat("Trade: ticket:%d; status:%d; bs:%s; type:%d; volume:%f; price:%f; sl:%f; tp:%f;", _ticket, _status, GetBuySell(), _orderType, _volume, _price, _stoploss, _takeprofit);
}