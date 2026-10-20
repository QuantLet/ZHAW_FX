<div style="margin: 0; padding: 0; text-align: center; border: none;">
<a href="https://quantlet.com" target="_blank" style="text-decoration: none; border: none;">
<img src="https://github.com/StefanGam/test-repo/blob/main/quantlet_design.png?raw=true" alt="Header Image" width="100%" style="margin: 0; padding: 0; display: block; border: none;" />
</a>
</div>

```
Name of Quantlet: MomentumStrategyFX

Published in: Currency hedging for SMEs and pension funds

Description: Contains the Momentum strategy for the cross-sectional portfolio. For our approach, we apply the algorithm presented by Baz et al. (2015) to generate the momentum signal, based on three crossovers of exponential moving averages with different time horizons. The three different crossovers identify short-, medium-, and long-term trends respectively. A signal is generated for each time horizon and then all these signals are combined to build a trade signal. Based on the generated trading signals, we create the portfolio with weights prespecified by user.

Keywords: 
- fx trading
- momentum
- cross sectional-portfolio
- FOREX
- trend prediction

See also: 

Author: Joerg Osterrieder, Piotr Kotlarz

Submitted: Wed, 27 2019 by Joerg Osterrieder and Piotr Kotlarz

Datafile: Data.RData, MomentumFunctions.R, MomentumPackages.R, MomentumStrategyFX.R

Example: Performance of momentum cross-sectional portfolio for a sample of the following currencies: EUR, AUD, NZD, JPY, CZK, PLN, CNY, CHF, GBP, CZK, SEK quoted against USD from December 2007 to January 2019.

```
<div align="center">
<img src="https://raw.githubusercontent.com/QuantLet/ZHAW_FX/master/MomentumStrategyFX/SummaryPlot.png" alt="Image" />
</div>

