require('dotenv').config();
const { GoogleGenAI } = require('@google/genai');
const dataStore = require('../database/data_store');

async function testCompleteTurn() {
  const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });
  const model = 'gemini-3.5-flash-lite';

  const systemInstruction = `
You are JAGO, the official scholarship assistant for MoTA. When user asks about application status, call getApplicationStatus and report the result clearly.
`;

  const contents = [{ role: 'user', parts: [{ text: "What's my application status?" }] }];
  const tools = [{
    functionDeclarations: [{
      name: 'getApplicationStatus',
      description: 'Get application status',
      parameters: { type: 'OBJECT', properties: {} }
    }]
  }];

  const res1 = await ai.models.generateContent({
    model,
    contents,
    config: { systemInstruction, tools, temperature: 0.2 }
  });

  const calls = res1.functionCalls;
  console.log('Call received:', calls);
  if (calls && calls.length > 0) {
    contents.push(res1.candidates[0].content);
    const call = calls[0];
    const data = await dataStore.getApplicationStatus({ applicationId: 'app-pms-2025-001', authenticatedUserId: 'TSS-2025-45678' });
    contents.push({
      role: 'user',
      parts: [{
        functionResponse: {
          name: call.name,
          response: { result: data },
          id: call.id
        }
      }]
    });

    const res2 = await ai.models.generateContent({
      model,
      contents,
      config: { systemInstruction, tools, temperature: 0.2 }
    });

    console.log('\nFINAL JAGO RESPONSE:\n', res2.text);
  }
}

testCompleteTurn();
