require('dotenv').config();
const { GoogleGenAI } = require('@google/genai');

async function testLive() {
  console.log('Testing live Gemini API with key:', process.env.GEMINI_API_KEY ? 'Present' : 'Missing');
  const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });
  const model = process.env.GEMINI_MODEL || 'gemini-3.8-flash';

  console.log('Model:', model);
  try {
    const res = await ai.models.generateContent({
      model: model,
      contents: 'Say hello in one word'
    });
    console.log('Success! Response:', res.text);
  } catch (err) {
    console.error('Error calling Gemini:', err);
  }
}

testLive();
