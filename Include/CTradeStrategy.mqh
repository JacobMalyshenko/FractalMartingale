//+------------------------------------------------------------------+
//|                                               CTradeStrategy.mqh |
//|                                                               KZ |
//|                                             https://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "KZ"
#property link      "https://www.mql4.com"
#property version   "1.00"
#property strict

#include <CFractal.mqh>
#include <CTradeList.mqh>
#include <CVolumeStrategy.mqh>
#include <CTradeStrategyProcessingContext.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTradeStrategy
  {
protected:
   string            _systemName;
   CVolumeStrategy*  _volumeStrategy;

   int               _slippage;
   double            _stoplossDelta;
   double            _takeprofitDelta;
   
   bool              _killSwitch;
   
      bool     IsFractalAlignWithTrade(CFractal* &fractal, CTrade *&trade);
      
      virtual CTradeStrategyProcessingContext* GetProcessingContext(CTradeList* &tradeList){return NULL;}
      virtual void CreateTrade(CTradeStrategyProcessingContext* &processingContext, CTradeList* &tradeList);
      virtual void CloseTrades(CTradeStrategyProcessingContext* &processingContext, CTradeList* &tradeList);
      virtual void UpdateTrades(CTradeStrategyProcessingContext* &processingContext, CTradeList* &tradeList){};

public:
      int   GetSlippage(){return _slippage;}

      CTradeStrategy(bool killSwitch);
      CTradeStrategy(bool killSwitch, CVolumeStrategy* &volumeStrategy, int slippage);
     ~CTradeStrategy();
     
      virtual void Process(CTradeList* &tradeList);
                          
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTradeStrategy::CTradeStrategy(bool killSwitch)
{
   _systemName = "CTradeStrategy";
   _stoplossDelta = 1;
   _takeprofitDelta = 1;
   
   _killSwitch = killSwitch;
   
   _volumeStrategy = NULL;
   _slippage = 0;
   PrintFormat("%s.Constructor", _systemName);
}

CTradeStrategy::CTradeStrategy(bool killSwitch, CVolumeStrategy* &volumeStrategy, int slippage)
{
   _systemName = "CTradeStrategy";
   _stoplossDelta = 1;
   _takeprofitDelta = 1;
   
   _killSwitch = killSwitch;
   
   _volumeStrategy = volumeStrategy;
   _slippage = slippage;
   PrintFormat("%s.Constructor", _systemName);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTradeStrategy::~CTradeStrategy()
{
   delete(_volumeStrategy);
   PrintFormat("%s.Destructor", _systemName);
}
//+------------------------------------------------------------------+

void CTradeStrategy::Process(CTradeList* &tradeList)
{
   if(_killSwitch) return;
   
   //Print("CTradeStrategy.Process");
   CTradeStrategyProcessingContext* processingContext = GetProcessingContext(tradeList);
   
   if(NULL == processingContext) return;
   
   if(processingContext.GetShouldClose())
   {
      CloseTrades(processingContext, tradeList);
   }
   if(processingContext.GetShouldOpen())
   {
      CreateTrade(processingContext, tradeList);
   }
   if(processingContext.GetShouldUpdate())
   {
      UpdateTrades(processingContext, tradeList);
   }
   
   delete(processingContext);
}

void CTradeStrategy::CreateTrade(CTradeStrategyProcessingContext* &processingContext, CTradeList* &tradeList)
{
   PrintFormat("%s.CreateTrade", _systemName);
   CTrade* trade;
   if(processingContext.GetShouldOpenSell())
   {
      trade = new CTrade(_Symbol,
            OP_SELL, 
            _volumeStrategy.GetNewVolume("S", tradeList), 
            Bid, 
            _slippage, 
            Bid + _stoplossDelta,
            MathMax(Bid - _takeprofitDelta, Point),
            _systemName);

      tradeList.Add(trade);
   }
   if(processingContext.GetShouldOpenBuy())
   {
      trade = new CTrade(_Symbol,
            OP_BUY, 
            _volumeStrategy.GetNewVolume("B", tradeList), 
            Ask, 
            _slippage, 
            MathMax(Ask - _stoplossDelta, Point),
            Ask + _takeprofitDelta,
            _systemName);

      tradeList.Add(trade);
   }
   
}

void CTradeStrategy::CloseTrades(CTradeStrategyProcessingContext* &processingContext, CTradeList* &tradeList)
{
   int size;
   
   if(processingContext.GetShouldCloseBuy())
   {
      size = tradeList.GetBuyCount();
      for(int i = 0; i < size; i++)
      {
         CTrade* trade = tradeList.GetBuyTrade(i);
         
         if(trade.GetStatus() != TS_NEW) trade.SetStatus(TS_CLOSED);
      }
   }
   if(processingContext.GetShouldCloseSell())
   {
      size = tradeList.GetSellCount();
      for(int i = 0; i < size; i++)
      {
         CTrade* trade = tradeList.GetSellTrade(i);
         
         if(trade.GetStatus() != TS_NEW) trade.SetStatus(TS_CLOSED);
      }
   }
}

bool CTradeStrategy::IsFractalAlignWithTrade(CFractal* &fractal, CTrade *&trade)
{
   string tradeBuySell = trade.GetBuySell();
   
   int fractalDirection = fractal.GetDirection();
   
   return (fractalDirection > 0 && tradeBuySell == "SELL") || (fractalDirection < 0 && tradeBuySell == "BUY");
}
