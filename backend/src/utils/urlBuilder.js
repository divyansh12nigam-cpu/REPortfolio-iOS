function normalize(str) {
  return str.toLowerCase().trim().replace(/\s+/g, '-');
}

function buildSearchUrl(city, locality, societyName) {
  const normalizedCity = normalize(city);

  // Tier 1: society-level search
  if (societyName && societyName.trim()) {
    const normalizedSociety = normalize(societyName);
    const normalizedLocality = normalize(locality || '');
    let url = 'https://www.99acres.com/property-for-sale-in-';
    if (normalizedSociety) url += `${normalizedSociety}-`;
    if (normalizedLocality) url += `${normalizedLocality}-`;
    url += `${normalizedCity}-ffid`;
    return { url, tier: 'society' };
  }

  // Tier 2: locality-level search
  if (locality && locality.trim()) {
    const normalizedLocality = normalize(locality);
    return {
      url: `https://www.99acres.com/property-for-sale-in-${normalizedLocality}-${normalizedCity}-ffid`,
      tier: 'locality',
    };
  }

  // Tier 3: city-level search
  return {
    url: `https://www.99acres.com/property-for-sale-in-${normalizedCity}-ffid`,
    tier: 'city',
  };
}

function getTierUrls(city, locality, societyName) {
  const tiers = [];

  if (societyName && societyName.trim()) {
    tiers.push(buildSearchUrl(city, locality, societyName));
  }

  if (locality && locality.trim()) {
    tiers.push(buildSearchUrl(city, locality, null));
  }

  tiers.push(buildSearchUrl(city, null, null));

  return tiers;
}

module.exports = { buildSearchUrl, getTierUrls };
