//+------------------------------------------------------------------+
//|                                            FractalMartingale.mq4 |
//|                                                               KZ |
//|                                             https://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "KZ"
#property link      "https://www.mql4.com"
#property version   "1.35"
#property description "Trailing stop by Low over breakeven level for ALL trades. Add max non-martingale open lot."
#property strict

#include <CVolumeMMPMStrategy.mqh>
#include <CVolumeKStrategy.mqh>

#include <CTradeStrategy.mqh>
#include <CTradeSingleStrategy.mqh>
#include <CTradeMartingaleStrategy.mqh>

#include <CTradeNoLossDrawStrategy.mqh>

#include <CTradeBaseController.mqh>


input int      AdviserID = 15777;
input double   BaseVolume = 0.01;
input double   MaxBaseVolume = 0.2;
input double   DollarMultiplier = 5000;
input double   MartingaleMultiplicator = 3;
input int      TradeSlippage = 0;

input int      MartingaleGridSize = 600;

input bool     MartingaleIsOn = true;
input bool     MMIsOn = true;

CTradeBaseController* _tradeController;

int OnInit()
{
   Print("MODE_LOTSIZE: ", MarketInfo(Symbol(), MODE_LOTSIZE));
   Print("MODE_MINLOT: ", MarketInfo(Symbol(), MODE_MINLOT));
   Print("MODE_LOTSTEP: ", MarketInfo(Symbol(), MODE_LOTSTEP));
   Print("MODE_MAXLOT: ", MarketInfo(Symbol(), MODE_MAXLOT));
   PrintFormat("Point: %f", Point);

   CVolumeMMPMStrategy* mmStrategy = new CVolumeMMPMStrategy(!MMIsOn, BaseVolume, DollarMultiplier, 
                                                              MaxBaseVolume, MartingaleMultiplicator, MartingaleGridSize);
   CVolumeKStrategy* kStrategy = new CVolumeKStrategy(false, BaseVolume, MartingaleMultiplicator);
   
   CTradeStrategy* strategies[];
   ArrayResize(strategies, 3);
   
   strategies[0] = new CTradeSingleStrategy(false, mmStrategy, TradeSlippage);
   strategies[1] = new CTradeMartingaleStrategy(!MartingaleIsOn, kStrategy, TradeSlippage, MartingaleGridSize);
   strategies[2] = new CTradeNoLossDrawStrategy(false);
   _tradeController = new CTradeBaseController(AdviserID, strategies);

   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   delete(_tradeController);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   _tradeController.PullSync();
   
   _tradeController.ProcessStrategy();

   _tradeController.PushSync();
  }
//+------------------------------------------------------------------+
