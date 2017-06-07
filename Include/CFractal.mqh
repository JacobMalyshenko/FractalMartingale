//+------------------------------------------------------------------+
//|                                                     CFractal.mqh |
//|                                                               KZ |
//|                                             https://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "KZ"
#property link      "https://www.mql4.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CFractal
  {
private:
   datetime _time;
   double   _value;
   int      _direction;

public:
                     CFractal(datetime time, double value, int direction);
                    ~CFractal();
                    
                    datetime GetTime(){return _time;}
                    double GetValue(){return _value;}
                    int GetDirection(){return _direction;}
                    
                    void        Print();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CFractal::CFractal(datetime time, double value, int direction)
{
   _time = time;
   _value = value;
   _direction = direction;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CFractal::~CFractal()
  {
  }
//+------------------------------------------------------------------+

void CFractal::Print()
{
   PrintFormat("Fractal: direction:%s; value:%f; time:%s", 
      _direction > 0 ? "UP" : _direction < 0 ? "DOWN" : "NONE",
      _value,
      TimeToString(_time));
}