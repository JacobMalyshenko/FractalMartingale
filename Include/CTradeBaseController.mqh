//+------------------------------------------------------------------+
//|                                         CTradeBaseController.mqh |
//|                                                               KZ |
//|                                             https://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "KZ"
#property link      "https://www.mql4.com"
#property version   "1.00"
#property strict


#include <ETradeStatus.mqh>
#include <CTradeList.mqh>
#include <CTradeStrategy.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTradeBaseController
{
protected:
   int               _adviserID;
   CTradeStrategy*   _strategies[];
   CTradeList*           _tradeList;
   
public:
                     CTradeBaseController(int adviserID, CTradeStrategy* &strategies[]);
                    ~CTradeBaseController();
                    
                    void PullSync();
                    void PushSync();
                    
                    virtual void ProcessStrategy();
                    
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTradeBaseController::CTradeBaseController(int adviserID, CTradeStrategy* &strategies[])
{
   _adviserID = adviserID;
   _tradeList = new CTradeList();
   ArrayCopy(_strategies, strategies);
   
   Print("CTradeBaseController.Constructor");
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTradeBaseController::~CTradeBaseController()
{
   delete(_tradeList);
   
   int size = ArraySize(_strategies);
   for(int i = 0; i < size; i++)
   {
      delete(_strategies[i]);
   }
   Print("CTradeBaseController.Destructor");
}
//+------------------------------------------------------------------+

void CTradeBaseController::ProcessStrategy()
{
   int size = ArraySize(_strategies);
   for(int i = 0; i < size; i++)
   {
      _strategies[i].Process(_tradeList);
   }
}

void CTradeBaseController::PullSync()
{
   int tradeList[][2];
   int srvTradeCount = OrdersTotal();

   ArrayResize(tradeList, srvTradeCount);
   
   //iterate through remote active
   for(int i = 0; i < srvTradeCount; i++)
   {
      if(OrderSelect(i, SELECT_BY_POS))
      {
         if(OrderMagicNumber() != _adviserID) continue;
         
         tradeList[i][0] = OrderOpenTime();
         tradeList[i][1] = OrderTicket();
      }
      else
         Print(__FUNCTION__," OrderSelect returned the error of ",GetLastError());
   }
   if(srvTradeCount > 0)
      ArraySort(tradeList, WHOLE_ARRAY, 0, MODE_ASCEND);
   
   for(int i = 0; i < srvTradeCount; i++)
   {
      if(OrderSelect(tradeList[i][1], SELECT_BY_TICKET))
      {
         CTrade* newTrade = new CTrade(OrderTicket(),
               _Symbol,
               OrderType(), 
               OrderLots(),
               OrderOpenPrice(),
               OrderOpenTime(),
               OrderStopLoss(),
               OrderTakeProfit(),
               OrderProfit() + 2 * (OrderSwap() + OrderCommission()),
               OrderComment());
      
         //add trade into list
         _tradeList.Add(newTrade);
      }
   }
}

void CTradeBaseController::PushSync()
{
   //iterate through local
   int localTradeCount = _tradeList.GetCount();
   for(int i = 0; i < localTradeCount; i++)
   {
      CTrade* trade = _tradeList.GetTrade(i);
      
      //modify only dirty trades
      if(!trade.IsDirty()) continue;
      
      int ticket = trade.GetTicket();
      switch(trade.GetStatus())
      {
         case TS_NEW: //create new trade
            //send trade for execution
            ticket = OrderSend(trade.GetSymbol(),
                     trade.GetOrderType(), 
                     NormalizeDouble(trade.GetVolume(), Digits),
                     NormalizeDouble(trade.GetPrice(), Digits),
                     trade.GetSlippage(), 
                     NormalizeDouble(trade.GetStoploss(), Digits),
                     NormalizeDouble(trade.GetTakeprofit(), Digits),
                     trade.GetComment(),
                     _adviserID);
               if(ticket < 0)
               {
                  Print(__FUNCTION__,"OrderSend returned the error of ",GetLastError());
                  trade.Print();
               }
            break;
         case TS_PENDING: //modify pending or active trade
         case TS_ACTIVE:
            if(!OrderModify(ticket,
                  NormalizeDouble(trade.GetPrice(), Digits),
                  NormalizeDouble(trade.GetStoploss(), Digits),
                  NormalizeDouble(trade.GetTakeprofit(), Digits),
                  0))
            {
               Print(__FUNCTION__," OrderModify returned the error of ",GetLastError(), " for ticket:#", ticket);
               trade.Print();
            }
            break;
         case TS_CLOSED: // close trade
            switch(trade.GetOrderType())
            {
               case OP_BUYLIMIT:
               case OP_BUYSTOP:
               case OP_SELLLIMIT:
               case OP_SELLSTOP:
                  if(!OrderDelete(ticket))
                  {
                     Print(__FUNCTION__,"OrderDelete returned the error of ",GetLastError(), " for ticket:#", ticket);
                     trade.Print();
                  }
                  break;
               case OP_BUY:
                  if(!OrderClose(ticket,
                        NormalizeDouble(trade.GetVolume(), Digits),
                        Bid,
                        _strategies[0].GetSlippage()))
                  {
                     Print(__FUNCTION__,"OrderClose returned the error of ",GetLastError(), " for ticket:#", ticket);
                     trade.Print();
                  }
                  break;
               case OP_SELL:
                  if(!OrderClose(ticket,
                        NormalizeDouble(trade.GetVolume(), Digits),
                        Ask,
                        _strategies[0].GetSlippage()))
                  {
                     Print(__FUNCTION__,"OrderClose returned the error of ",GetLastError(), " for ticket:#", ticket);
                     trade.Print();
                  }
                  break;
            }
            break;
      }
   }
   _tradeList.Clear();
}
