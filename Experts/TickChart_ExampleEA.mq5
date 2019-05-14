#property copyright "Copyright 2019, AZ-iNVEST"
#property link      "http://www.az-invest.eu"
#property version   "2.05"
#property description "Example EA showing the way to use the TickChart class defined in TickChart.mqh" 

//
// SHOW_INDICATOR_INPUTS *NEEDS* to be defined, if the EA needs to be *tested in MT5's backtester*
// -------------------------------------------------------------------------------------------------
// Using '#define SHOW_INDICATOR_INPUTS' will show the TickChart indicator's inputs 
// NOT using the '#define SHOW_INDICATOR_INPUTS' statement will read the settigns a chart with 
// the TickChart indicator attached.
//

//#define SHOW_INDICATOR_INPUTS

//
// You need to include the TickChart.mqh header file
//

#include <AZ-INVEST/SDK/TickChart.mqh>
//
//  To use the TickChart indicator in your EA you need do instantiate the indicator class (TickChart)
//  and call the Init() method in your EA's OnInit() function.
//  Don't forget to release the indicator when you're done by calling the Deinit() method.
//  Example shown in OnInit & OnDeinit functions below:
//

TickChart * tickChart;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   tickChart = new TickChart(MQLInfoInteger((int)MQL5_TESTING) ? false : true);
   if(tickChart == NULL)
      return(INIT_FAILED);
   
   tickChart.Init();
   if(tickChart.GetHandle() == INVALID_HANDLE)
      return(INIT_FAILED);
   
   //
   //  your custom code goes here...
   //
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(tickChart != NULL)
   {
      tickChart.Deinit();
      delete tickChart;
   }
   
   //
   //  your custom code goes here...
   //
}

//
//  At this point you may use the tick chart data fetching methods in your EA.
//  Brief demonstration presented below in the OnTick() function:
//

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   //
   // It is considered good trading & EA coding practice to perform calculations
   // when a new bar is fully formed. 
   // The IsNewBar() method is used for checking if a new tick chart bar has formed 
   //
   
   if(tickChart.IsNewBar())
   {
      //
      //  There are two methods for getting the Moving Average values.
      //  The example below gets the moving average values for 3 latest bars
      //  counting to the left from the most current (uncompleted) bar.
      //
      
      int startAtBar = 0;   // get value starting from the most current (uncompleted) bar.
      int numberOfBars = 3; // gat a total of 3 MA values (for the 3 latest bars)
      
      //
      // Values will be stored in 2 arrays defined below
      //
      
      double MA1[]; // array to be filled by values of the first moving average
      double MA2[]; // array to be filled by values of the second moving average
      
      if(tickChart.GetMA1(MA1,startAtBar,numberOfBars) && tickChart.GetMA2(MA2,startAtBar,numberOfBars))
      {
         //
         // Values are stored in the MA1 and MA2 arrays and are now ready for use
         //
         // MA1[0] contains the 1st moving average value for the latest (uncompleted) bar
         // MA1[1] contains the 1st moving average value for the 1st bar to the left from the latest (uncompleted) bar
         // MA1[2] contains the 1st moving average value for the 2nd bar to the left from the latest (uncompleted) bar
         // MA1[3]..MA1[n] do not exist since we retrieved the values for 3 bars (defined by "numnberOfBars")
         //
         // The values for the 2nd and 3rd moving average are stored in MA2[] & MA3[] 
         // and are accessed identically to values of MA1[] (shown above)
      }
      
      //
      // Getting the MqlRates info for tick chart bars is done using the
      // GetMqlRates(MqlRates &ratesInfoArray[], int start, int count) 
      // method. Example below:
      //
      
      MqlRates TickChartRatesInfoArray[]; // This array will store the MqlRates data for tick chart
      startAtBar = 0;                     // get values starting from the last completed bar.
      numberOfBars = 3;                   // gat a total of 3 MqlRates values (for 3 bars starting from bar 0 (current uncompleted))
      
      if(tickChart.GetMqlRates(TickChartRatesInfoArray,startAtBar,numberOfBars))
      {         
         //
         //  Check if a reversal bar has formed
         //
       
         string infoString;
         
         if((TickChartRatesInfoArray[1].open < TickChartRatesInfoArray[1].close) &&
            (TickChartRatesInfoArray[2].open > TickChartRatesInfoArray[2].close))
         {
            // bullish reversal
            infoString = "Previous bar formed bullish reversal";
         }
         else if((TickChartRatesInfoArray[1].open > TickChartRatesInfoArray[1].close) &&
            (TickChartRatesInfoArray[2].open < TickChartRatesInfoArray[2].close))
         {
            // bearish reversal
            infoString = "Previous bar formed bearish reversal";
         }
         else
         {
            infoString = "";
         }
      
         //
         //  Output some data to chart
         //
      
         Comment("\nNew bar opened on "+(string)TickChartRatesInfoArray[0].time+
                 "\nPrevious bar OPEN price:"+DoubleToString(TickChartRatesInfoArray[1].open,_Digits)+", bar opened on "+(string)TickChartRatesInfoArray[1].time+
                 "\n"+infoString+ 
                 "\n");
      }
      
      //
      // All charts that contain real volume information (i.e. stocks, futures, ...)
      // also contain the brekdown of volume into BUY, SELL and BUY/SELL volume.
      // This data is accessed using the
      // GetBuySellVolumeBreakdown(long &buy[], long &sell[], long &buySell[], int start, int count)
      // method. Example below:
      
      double buyVolume[];      // This array will store the values of the BUY volume 
      double sellVolume[];     // This array will store the values of the SELL volume
      double buySellVolume[];  // This array will store the values of the BUY/SELL volume
      
      // When you add BUY, SELL and BUY/SELL volume numbers for a bar they will be equal 
      // to the Real Volume number that can be accessed using the
      // GetMqlRates(MqlRates &ratesInfoArray[], int start, int count) 
      // metod described above.

      startAtBar   = 1;    // get values starting from the last completed bar.
      numberOfBars = 2;    // gat a total of 2 values (for 2 bars starting from bar 1 (last completed))
      
      if(tickChart.GetBuySellVolumeBreakdown(buyVolume,sellVolume,buySellVolume,startAtBar,numberOfBars))
      {
         //
         // Apply your real volume analysis logic here...
         //         
      }
      
      //
      // Getting Donchain channel values is done using the
      // GetDonchian(double &HighArray[], double &MidArray[], double &LowArray[], int start, int count) 
      // method. Example below:
      //
      
      double HighArray[];  // This array will store the values of the high band
      double MidArray[];   // This array will store the values of the middle band
      double LowArray[];   // This array will store the values of the low band
      
      startAtBar   = 1;    // get values starting from the last completed bar.
      numberOfBars = 20;   // gat a total of 20 values (for 20 bars starting from bar 1 (last completed))
      
      if(tickChart.GetDonchian(HighArray,MidArray,LowArray,startAtBar,numberOfBars))
      {
         //
         // Apply your Donchian channel logic here...
         //
      }
      
      //
      // Getting Bollinger Bands values is done using the
      // GetBollingerBands(double &HighArray[], double &MidArray[], double &LowArray[], int start, int count) 
      // method. Example below:
      //
      
      // HighArray[] array will store the values of the high band
      // MidArray[] array will store the values of the middle band
      // LowArray[] array will store the values of the low band
      
      startAtBar   = 1;    // get values starting from the last completed bar.
      numberOfBars = 10;   // gat a total of 10 values (for 10 bars starting from bar 1 (last completed))     
      
      if(tickChart.GetBollingerBands(HighArray,MidArray,LowArray,startAtBar,numberOfBars))
      {
         //
         // Apply your Bollinger Bands logic here...
         //
      } 

      //
      // Getting SuperTrend values is done using the
      // GetSuperTrend(double &SuperTrendHighArray[], double &SuperTrendArray[], double &SuperTrendLowArray[], int start, int count) 
      // method. Example below:
      //
      
      // HighArray[] array will store the values of the high SuperTrend line
      // MidArray[] array will store the values of the SuperTrend value
      // LowArray[] array will store the values of the low SuperTrend line
      
      startAtBar   = 1;   // get values starting from the last completed bar.
      numberOfBars = 3;   // gat a total of 3 values (for 3 bars starting from bar 1 (last completed))     
      
      if(tickChart.GetSuperTrend(HighArray,MidArray,LowArray,startAtBar,numberOfBars))
      {
         //
         // Apply your SuperTrend logic here...
         //
      } 
      
   } 
}
