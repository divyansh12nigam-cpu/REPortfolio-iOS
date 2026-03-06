const axios = require('axios');
const cheerio = require('cheerio');
const { getTierUrls } = require('../utils/urlBuilder');
const { getPricePerSqft } = require('../utils/cityBasePrice');

const USER_AGENTS = [
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
  'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36',
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/121.0',
];

function randomUserAgent() {
  return USER_AGENTS[Math.floor(Math.random() * USER_AGENTS.length)];
}

function delay(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function median(arr) {
  if (arr.length === 0) return 0;
  const sorted = [...arr].sort((a, b) => a - b);
  const mid = Math.floor(sorted.length / 2);
  return sorted.length % 2 !== 0
    ? sorted[mid]
    : (sorted[mid - 1] + sorted[mid]) / 2;
}

function filterOutliers(prices) {
  if (prices.length < 3) return prices;
  const med = median(prices);
  return prices.filter((p) => p > med * 0.33 && p < med * 3);
}

function parsePrice(text) {
  if (!text) return null;
  const cleaned = text.replace(/[^\d.]/g, '');
  if (!cleaned) return null;

  const num = parseFloat(cleaned);
  if (isNaN(num)) return null;

  const lower = text.toLowerCase();
  if (lower.includes('cr') || lower.includes('crore')) return num * 10000000;
  if (lower.includes('lac') || lower.includes('lakh') || lower.includes('l'))
    return num * 100000;
  if (lower.includes('k') || lower.includes('thousand')) return num * 1000;

  return num;
}

function parseArea(text) {
  if (!text) return null;
  const match = text.match(/([\d,]+)\s*(?:sq\.?\s*ft|sqft|sft)/i);
  if (match) {
    return parseInt(match[1].replace(/,/g, ''), 10);
  }
  return null;
}

async function scrapeSearchPage(url) {
  try {
    const response = await axios.get(url, {
      headers: {
        'User-Agent': randomUserAgent(),
        Accept:
          'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.9',
      },
      timeout: 30000,
    });

    const $ = cheerio.load(response.data);
    const pricesPerSqft = [];

    // Strategy 1: Look for listing tuples with price and area
    $('[class*="listing"], [class*="property"], [class*="card"], [class*="tuple"]').each(
      (_, el) => {
        const elText = $(el).text();
        const price = parsePrice(
          $(el).find('[class*="price"], [class*="Price"], [class*="val"]').first().text() ||
            elText.match(/₹\s*[\d.,]+\s*(?:Cr|Lac|Lakh|L|K)?/i)?.[0]
        );
        const area = parseArea(elText);

        if (price && area && area > 0) {
          const ppsf = price / area;
          if (ppsf > 500 && ppsf < 100000) {
            pricesPerSqft.push(ppsf);
          }
        }
      }
    );

    // Strategy 2: Look for explicit price-per-sqft mentions
    if (pricesPerSqft.length === 0) {
      const bodyText = $('body').text();
      const ppsfMatches = bodyText.match(
        /₹\s*([\d,]+)\s*(?:\/|per)\s*(?:sq\.?\s*ft|sqft)/gi
      );
      if (ppsfMatches) {
        for (const match of ppsfMatches) {
          const numMatch = match.match(/[\d,]+/);
          if (numMatch) {
            const val = parseInt(numMatch[0].replace(/,/g, ''), 10);
            if (val > 500 && val < 100000) {
              pricesPerSqft.push(val);
            }
          }
        }
      }
    }

    return pricesPerSqft;
  } catch (err) {
    console.log(`[Scraper] Failed to fetch ${url}: ${err.message}`);
    return [];
  }
}

async function scrapeComparables(city, locality, societyName, floorPlan) {
  const tierUrls = getTierUrls(city, locality, societyName);

  for (const { url, tier } of tierUrls) {
    console.log(`[Scraper] Trying tier "${tier}": ${url}`);
    const prices = await scrapeSearchPage(url);
    const filtered = filterOutliers(prices);

    if (filtered.length > 0) {
      const medianPrice = median(filtered);
      console.log(
        `[Scraper] Found ${filtered.length} comparables at tier "${tier}", median ₹${Math.round(medianPrice)}/sqft`
      );
      return {
        pricePerSqft: Math.round(medianPrice),
        comparableCount: filtered.length,
        searchTier: tier,
        source: '99acres',
        confidence:
          tier === 'society'
            ? 'high'
            : tier === 'locality'
              ? 'medium'
              : 'low',
      };
    }

    // Delay between tier attempts to avoid rate limiting
    await delay(500);
  }

  // Tier 4: fallback to city base price
  console.log(`[Scraper] All tiers exhausted for ${city}/${locality}, using city base price`);
  return {
    pricePerSqft: getPricePerSqft(city),
    comparableCount: 0,
    searchTier: 'fallback',
    source: 'city_base_price',
    confidence: 'estimated',
  };
}

module.exports = { scrapeComparables };
