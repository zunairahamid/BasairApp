const express = require('express');
const pdfParse = require('pdf-parse');  // This works in v1.x
const cors = require('cors');
const app = express();
app.use(cors());
app.use(express.raw({ type: 'application/pdf', limit: '10mb' }));

app.post('/extract-text', async (req, res) => {
  console.log('Received PDF, size:', req.body.length);
  console.log('pdfParse type:', typeof pdfParse);  // Should be 'function'
  try {
    console.log('Starting PDF parsing...');
    const data = await pdfParse(req.body);
    console.log('PDF parsed successfully, text length:', data.text.length);
    res.json({ text: data.text });
  } catch (error) {
    console.error('PDF parsing error:', error.message);
    res.status(500).json({ error: 'Extraction failed', details: error.message });
  }
});

app.listen(3000, () => console.log('Server running on http://localhost:3000'));