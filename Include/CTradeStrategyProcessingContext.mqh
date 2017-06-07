//+------------------------------------------------------------------+
//|                              CTradeStrategyProcessingContext.mqh |
//|                                                               KZ |
//|                                             https://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "KZ"
#property link      "https://www.mql4.com"
#property version   "1.00"
#property strict

#include <CFractal.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTradeStrategyProcessingContext
  {
private:
   CFractal*   _fractal;
   bool        _shouldOpenBuy;
   bool        _shouldOpenSell;
   bool        _shouldCloseBuy;
   bool        _shouldCloseSell;
   bool        _shouldUpdateBuy;
   bool        _shouldUpdateSell;
   
public:
                     CTradeStrategyProcessingContext(CFractal* &fractal, bool shouldOpenBuy, bool shouldOpenSell, bool shouldCloseBuy, bool shouldCloseSell);
                     CTradeStrategyProcessingContext(CFractal* &fractal, bool shouldOpenBuy, bool shouldOpenSell, bool shouldCloseBuy, bool shouldCloseSell, bool shouldUpdateBuy, bool shouldUpdateSell);
                    ~CTradeStrategyProcessingContext();
                    
                    CFractal* GetFractal(){return _fractal;}
                    bool      GetShouldOpen(){return _shouldOpenBuy || _shouldOpenSell;}
                    bool      GetShouldOpenBuy(){return _shouldOpenBuy;}
                    bool      GetShouldOpenSell(){return _shouldOpenSell;}
                    
                    bool      GetShouldClose(){return _shouldCloseBuy || _shouldCloseSell;}
                    bool      GetShouldCloseBuy(){return _shouldCloseBuy;}
                    bool      GetShouldCloseSell(){return _shouldCloseSell;}

                    bool      GetShouldUpdate(){return _shouldUpdateBuy || _shouldUpdateSell;}
                    bool      GetShouldUpdateBuy(){return _shouldUpdateBuy;}
                    bool      GetShouldUpdateSell(){return _shouldUpdateSell;}

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTradeStrategyProcessingContext::CTradeStrategyProcessingContext(CFractal* &fractal, bool shouldOpenBuy, bool shouldOpenSell, bool shouldCloseBuy, bool shouldCloseSell)
   {
   _fractal = fractal;
   _shouldOpenBuy = shouldOpenBuy;
   _shouldOpenSell = shouldOpenSell;
   _shouldCloseBuy = shouldCloseBuy;
   _shouldCloseSell = shouldCloseSell;
   _shouldUpdateBuy = false;
   _shouldUpdateSell = false;
}
   
CTradeStrategyProcessingContext::CTradeStrategyProcessingContext(CFractal* &fractal, bool shouldOpenBuy, bool shouldOpenSell, bool shouldCloseBuy, bool shouldCloseSell, bool shouldUpdateBuy, bool shouldUpdateSell)
{
   _fractal = fractal;
   _shouldOpenBuy = shouldOpenBuy;
   _shouldOpenSell = shouldOpenSell;
   _shouldCloseBuy = shouldCloseBuy;
   _shouldCloseSell = shouldCloseSell;
   _shouldUpdateBuy = shouldUpdateBuy;
   _shouldUpdateSell = shouldUpdateSell;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTradeStrategyProcessingContext::~CTradeStrategyProcessingContext()
{
}
//+------------------------------------------------------------------+
