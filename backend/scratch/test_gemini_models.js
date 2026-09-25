require('dotenv').config();
const { GoogleGenAI } = require('@google/genai');

async function testModels() {
  const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });
  try {
    const list = await ai.models.list();
    console.log('Available models:');
    for await (const m of list) {
      if (m.name.includes('flash') || m.name.includes('gemini')) {
        console.log('-', m.name, '| Display:', m.displayName);
      }
    }
  } catch (err) {
    console.error('Error listing models:', err.message);
  }
}

testModels();
