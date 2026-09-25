require('dotenv').config();
const { GoogleGenAI } = require('@google/genai');
const dataStore = require('../database/data_store');
const { functionDeclarations } = require('../services/gemini_service');

async function testFunctionCalling() {
  const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });
  const model = 'gemini-flash-latest';

  console.log('Testing function calling with model:', model);
  try {
    const response = await ai.models.generateContent({
      model: model,
      contents: [{ role: 'user', parts: [{ text: 'Give me details for Pre-Matric Scholarship' }] }],
      config: {
        systemInstruction: 'You are JAGO, scholarship assistant. Use getScholarshipDetails tool when asked for details of a scheme.',
        tools: [{ functionDeclarations }],
        temperature: 0.2
      }
    });

    console.log('Function calls from model:', JSON.stringify(response.functionCalls, null, 2));
    if (response.text) {
      console.log('Text response:', response.text);
    }
  } catch (err) {
    console.error('Error in function calling:', err);
  }
}

testFunctionCalling();
