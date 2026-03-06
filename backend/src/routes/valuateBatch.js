const express = require('express');
const { scrapeComparables } = require('../services/scrapingService');
const { computeValuation } = require('../services/valuationService');
const cache = require('../services/cacheService');

const router = express.Router();

router.post('/valuate-batch', async (req, res) => {
  try {
    const { properties } = req.body;

    if (!properties || !Array.isArray(properties) || properties.length === 0) {
      return res.status(400).json({ error: 'properties array is required' });
    }

    console.log(
      `[valuate-batch] Processing ${properties.length} properties...`
    );

    const valuations = [];
    let totalInvested = 0;
    let totalCurrentValue = 0;
    let totalGrowth = 0;
    let totalAnnualRental = 0;

    // Process sequentially to avoid hammering 99acres
    for (const prop of properties) {
      const floorPlan = prop.floorPlan || '';

      // Check cache first
      let scrapedData = cache.get(prop.city, prop.locality, floorPlan);

      if (!scrapedData) {
        console.log(
          `[valuate-batch] Cache miss for ${prop.city}/${prop.locality}, scraping...`
        );
        scrapedData = await scrapeComparables(
          prop.city,
          prop.locality,
          prop.societyName,
          floorPlan
        );
        cache.set(prop.city, prop.locality, floorPlan, scrapedData);
      } else {
        console.log(
          `[valuate-batch] Cache hit for ${prop.city}/${prop.locality}`
        );
      }

      const valuation = computeValuation(prop, scrapedData);
      valuations.push(valuation);

      totalInvested += Number(prop.purchasePrice) || 0;
      totalCurrentValue += valuation.fairValue;
      totalGrowth += valuation.growth;
      totalAnnualRental += valuation.annualRent;
    }

    const growthPercent =
      totalInvested > 0 ? (totalGrowth / totalInvested) * 100 : 0;

    const response = {
      valuations,
      summary: {
        totalInvested,
        totalCurrentValue,
        totalGrowth,
        growthPercent,
        totalAnnualRental,
      },
    };

    console.log(
      `[valuate-batch] Done. ${valuations.length} valuations computed.`
    );
    res.json(response);
  } catch (err) {
    console.error('[valuate-batch] Error:', err.message);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
