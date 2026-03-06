const express = require('express');
const cors = require('cors');
const valuateBatchRouter = require('./routes/valuateBatch');
const portfolioSummaryRouter = require('./routes/portfolioSummary');

const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

// Health check for UptimeRobot keepalive
app.get('/health', (req, res) => {
  res.json({ status: 'ok', uptime: process.uptime() });
});

// Routes
app.use('/', valuateBatchRouter);
app.use('/', portfolioSummaryRouter);

app.listen(PORT, () => {
  console.log(`[Server] REPortfolio valuation service running on port ${PORT}`);
});
