require('dotenv').config();
const { GoogleGenAI } = require('@google/genai');

async function testCandidateModels() {
  const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });
  const candidates = ['gemini-2.5-flash', 'gemini-flash-latest', 'gemini-2.5-flash-lite', 'gemini-3.8-flash'];

  for (const model of candidates) {
    try {
      console.log(`Trying model: ${model}...`);
      const res = await ai.models.generateContent({
        model: model,
        contents: 'Give a 1-sentence description of what a scholarship is.'
      });
      console.log(`✅ SUCCESS with ${model}:`, res.text.trim());
      return model;
    } catch (err) {
      console.log(`❌ Failed with ${model}: ${err.message}`);
    }
  }
}

testCandidateModels();
