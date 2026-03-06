const FIFTEEN_DAYS_MS = 15 * 24 * 60 * 60 * 1000;

class CacheService {
  constructor(ttlMs = FIFTEEN_DAYS_MS) {
    this.cache = new Map();
    this.ttlMs = ttlMs;
  }

  _makeKey(city, locality, floorPlan) {
    return `${(city || '').toLowerCase()}|${(locality || '').toLowerCase()}|${(floorPlan || '').toLowerCase()}`;
  }

  get(city, locality, floorPlan) {
    const key = this._makeKey(city, locality, floorPlan);
    const entry = this.cache.get(key);
    if (!entry) return null;
    if (Date.now() - entry.timestamp > this.ttlMs) {
      this.cache.delete(key);
      return null;
    }
    return entry.value;
  }

  set(city, locality, floorPlan, value) {
    const key = this._makeKey(city, locality, floorPlan);
    this.cache.set(key, { value, timestamp: Date.now() });
  }

  has(city, locality, floorPlan) {
    return this.get(city, locality, floorPlan) !== null;
  }
}

module.exports = new CacheService();
