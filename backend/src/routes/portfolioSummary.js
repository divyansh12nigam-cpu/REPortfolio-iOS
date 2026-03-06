const express = require('express');
const { getPricePerSqft } = require('../utils/cityBasePrice');

const router = express.Router();

router.post('/portfolio-summary', async (req, res) => {
  try {
    const { properties } = req.body;

    if (!properties || !Array.isArray(properties) || properties.length === 0) {
      return res.status(400).json({ error: 'properties array is required' });
    }

    console.log(
      `[portfolio-summary] Computing summary for ${properties.length} properties...`
    );

    let totalInvested = 0;
    let totalCurrentValue = 0;
    let totalGrowth = 0;
    let totalAnnualRental = 0;

    const apiProperties = properties.map((p) => {
      const pricePerSqft = getPricePerSqft(p.city);
      const areaSqft = p.areaSqft || 1000;
      const fairValue = pricePerSqft * areaSqft;
      const valueLow = fairValue * 0.95;
      const valueHigh = fairValue * 1.05;
      const purchasePrice = Number(p.purchasePrice) || 0;
      const growth = valueHigh - purchasePrice;
      const growthPercent =
        purchasePrice > 0 ? (growth / purchasePrice) * 100 : 0;
      const monthlyRent = p.monthlyRent || 0;
      const annualRent = monthlyRent * 12;

      totalInvested += purchasePrice;
      totalCurrentValue += valueHigh;
      totalGrowth += growth;
      totalAnnualRental += annualRent;

      return {
        projectName: p.projectName,
        value_range_low: valueLow,
        value_range_high: valueHigh,
        fair_value: fairValue,
        growth,
        growth_percent: growthPercent,
        monthly_rent: monthlyRent,
        annual_rent: annualRent,
        status: monthlyRent > 0 ? 'On Rent' : 'Self Use',
      };
    });

    const portfolioGrowthPercent =
      totalInvested > 0 ? (totalGrowth / totalInvested) * 100 : 0;

    const response = {
      summary: {
        total_invested: totalInvested,
        total_current_value: totalCurrentValue,
        total_growth: totalGrowth,
        portfolio_growth_percent: portfolioGrowthPercent,
        total_annual_rental: totalAnnualRental,
      },
      properties: apiProperties,
    };

    res.json(response);
  } catch (err) {
    console.error('[portfolio-summary] Error:', err.message);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
