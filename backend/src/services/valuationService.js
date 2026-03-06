function computeValuation(property, scrapedData) {
  const areaSqft = property.areaSqft || 1000;
  const pricePerSqft = scrapedData.pricePerSqft;
  const fairValue = pricePerSqft * areaSqft;
  const valueLow = fairValue * 0.9;
  const valueHigh = fairValue * 1.1;
  const purchasePrice = Number(property.purchasePrice) || 0;
  const growth = fairValue - purchasePrice;
  const growthPercent =
    purchasePrice > 0 ? (growth / purchasePrice) * 100 : 0;
  const monthlyRent = property.monthlyRent || 0;
  const annualRent = monthlyRent * 12;
  const status = monthlyRent > 0 ? 'On Rent' : 'Self Use';

  return {
    projectName: property.projectName,
    valueLow,
    valueHigh,
    fairValue,
    pricePerSqft,
    growth,
    growthPercent,
    monthlyRent,
    annualRent,
    status,
    source: scrapedData.source,
    searchTier: scrapedData.searchTier,
    confidence: scrapedData.confidence,
    comparableCount: scrapedData.comparableCount,
    cachedAt: new Date().toISOString(),
  };
}

module.exports = { computeValuation };
