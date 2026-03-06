const cityBasePrice = {
  Ghaziabad: 3800,
  Noida: 5500,
  Gurugram: 7200,
  Delhi: 9000,
  Mumbai: 18000,
  Pune: 7500,
  Bengaluru: 6800,
  Hyderabad: 5800,
  Chennai: 6200,
  Kolkata: 4500,
};

const DEFAULT_BASE_PRICE = 5000;

function getPricePerSqft(city) {
  return cityBasePrice[city] || DEFAULT_BASE_PRICE;
}

module.exports = { cityBasePrice, DEFAULT_BASE_PRICE, getPricePerSqft };
