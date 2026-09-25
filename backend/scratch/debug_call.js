require('dotenv').config();
const { GoogleGenAI } = require('@google/genai');

async function debugCandidate() {
  const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });
  const res = await ai.models.generateContent({
    model: 'gemini-3.5-flash-lite',
    contents: 'What is my application status?',
    config: {
      systemInstruction: 'You are JAGO. You MUST call getApplicationStatus to check the user application status.',
      tools: [{
        functionDeclarations: [{
          name: 'getApplicationStatus',
          description: 'Get application status',
          parameters: { type: 'OBJECT', properties: {} }
        }]
      }]
    }
  });

  console.log('Candidates:', JSON.stringify(res.candidates, null, 2));
  console.log('functionCalls property:', res.functionCalls);
}

debugCandidate();
