const http = require('http');

function postChat(payload) {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify(payload);
    const req = http.request({
      hostname: 'localhost',
      port: 3000,
      path: '/api/jago/chat',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(data)
      }
    }, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          resolve(JSON.parse(body));
        } catch (e) {
          resolve({ raw: body });
        }
      });
    });
    req.on('error', reject);
    req.write(data);
    req.end();
  });
}

async function runTests() {
  console.log('====================================================');
  console.log('TESTING 11 EXACT USER-SPECIFIED QUESTIONS VIA LIVE BACKEND');
  console.log('====================================================\n');

  // Test 1: "Give me details for Pre-Matric Scholarship"
  console.log('1. Query: "Give me details for Pre-Matric Scholarship"');
  let res = await postChat({ message: 'Give me details for Pre-Matric Scholarship' });
  console.log('RESPONSE:\n', res.reply, '\n---\n');

  // Test 2: "What is a scholarship?"
  console.log('2. Query: "What is a scholarship?"');
  res = await postChat({ message: 'What is a scholarship?' });
  console.log('RESPONSE:\n', res.reply, '\n---\n');

  // Test 3: "What documents are required for Post-Matric?"
  console.log('3. Query: "What documents are required for Post-Matric?"');
  res = await postChat({ message: 'What documents are required for Post-Matric?' });
  console.log('RESPONSE:\n', res.reply, '\n---\n');

  // Test 4: "What is DBT?"
  console.log('4. Query: "What is DBT?"');
  res = await postChat({ message: 'What is DBT?' });
  console.log('RESPONSE:\n', res.reply, '\n---\n');

  // Test 5: "Who can apply for NFST?"
  console.log('5. Query: "Who can apply for NFST?"');
  res = await postChat({ message: 'Who can apply for NFST?' });
  console.log('RESPONSE:\n', res.reply, '\n---\n');

  // Test 6: "Tell me about NOS."
  console.log('6. Query: "Tell me about NOS."');
  res = await postChat({ message: 'Tell me about NOS.' });
  console.log('RESPONSE:\n', res.reply, '\n---\n');

  // Test 7: Multi-turn Conversation Context: "Tell me about Post-Matric" -> "What about income?"
  console.log('7. Multi-turn: "Tell me about Post-Matric" -> "What about income?"');
  const history = [
    { role: 'user', text: 'Tell me about Post-Matric Scholarship' },
    { role: 'model', text: 'Post-Matric Scholarship is for ST students in Class 11 to PG.' }
  ];
  res = await postChat({ message: 'What about income?', conversationHistory: history });
  console.log('RESPONSE:\n', res.reply, '\n---\n');

  // Test 8: "Am I eligible?"
  console.log('8. Query: "Am I eligible?"');
  res = await postChat({ message: 'Am I eligible?' });
  console.log('RESPONSE:\n', res.reply, '\n---\n');

  // Test 9: "What is my application status?"
  console.log('9. Query: "What is my application status?"');
  res = await postChat({
    message: 'What is my application status?',
    userId: 'TSS-2025-45678',
    applicationId: 'app-pms-2025-001'
  });
  console.log('RESPONSE:\n', res.reply, '\n---\n');

  // Test 10: "Write a Python program."
  console.log('10. Query: "Write a Python program."');
  res = await postChat({ message: 'Write a Python program.' });
  console.log('RESPONSE:\n', res.reply, '\n---\n');

  // Test 11: Specific official question not present in sources
  console.log('11. Query: "What is the exact scholarship quota for tribal students in Antarctica?"');
  res = await postChat({ message: 'What is the exact scholarship quota for tribal students in Antarctica?' });
  console.log('RESPONSE:\n', res.reply, '\n---\n');
}

runTests().catch(console.error);
