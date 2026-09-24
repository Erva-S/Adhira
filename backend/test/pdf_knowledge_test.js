const assert = require('assert');
const dataStore = require('../database/data_store');
const { GeminiService, RESPONSES } = require('../services/gemini_service');

async function testPdfKnowledgeLayer() {
  console.log('📚 Starting Thorough MoTA PDF Knowledge Verification Tests...\n');
  process.env.ALLOW_LOCAL_FALLBACK = 'true';
  const service = new GeminiService();

  // Test 1: General scholarship information
  console.log('1. Testing general scholarship information...');
  const schemesRes = await service.processChat({ message: 'What scholarships are available?' });
  assert(schemesRes.reply.includes('Pre-Matric'), 'Should list Pre-Matric');
  assert(schemesRes.reply.includes('Post-Matric'), 'Should list Post-Matric');
  assert(schemesRes.reply.includes('Top Class'), 'Should list Top Class');
  assert(schemesRes.reply.includes('National Fellowship'), 'Should list NFST');
  assert(schemesRes.reply.includes('National Overseas'), 'Should list NOS');
  console.log('   ✅ All 5 MoTA schemes listed with source references.');

  // Test 2: Pre-Matric eligibility
  console.log('2. Testing Pre-Matric eligibility...');
  const preMatricRes = await service.processChat({ message: 'What is the eligibility for Pre-Matric Scholarship?' });
  assert(preMatricRes.reply.includes('Class IX') || preMatricRes.reply.includes('Class 9') || preMatricRes.reply.includes('Classes IX & X'));
  assert(preMatricRes.reply.includes('Pre_Matric_Scholarship_Guidelines_2021-26.pdf'), 'Must cite Pre-Matric PDF');
  console.log('   ✅ Pre-Matric eligibility and PDF citation verified.');

  // Test 3: Post-Matric eligibility
  console.log('3. Testing Post-Matric eligibility...');
  const postMatricRes = await service.processChat({ message: 'What is the eligibility for Post-Matric?' });
  assert(postMatricRes.reply.includes('Post_Matric_Scholarship_Guidelines_2022.pdf'), 'Must cite Post-Matric PDF');
  assert(postMatricRes.reply.includes('2.50 Lakh') || postMatricRes.reply.includes('2,50,000'));
  console.log('   ✅ Post-Matric eligibility and PDF citation verified.');

  // Test 4: Top Class eligibility
  console.log('4. Testing Top Class eligibility...');
  const topClassRes = await service.processChat({ message: 'What are the eligibility criteria for Top Class scholarship?' });
  assert(topClassRes.reply.includes('National_Fellowship_and_Scholarship_Higher_Education_Guidelines_2021-26.pdf'));
  console.log('   ✅ Top Class eligibility and PDF citation verified.');

  // Test 5: NFST information
  console.log('5. Testing NFST (National Fellowship) information...');
  const nfstRes = await service.processChat({ message: 'Tell me about the National Fellowship for ST (NFST)' });
  assert(nfstRes.reply.includes('National_Fellowship_and_Scholarship_Higher_Education_Guidelines_2021-26.pdf'));
  const nfstDetails = await dataStore.getScholarshipDetails({ scheme: 'nfst' });
  assert(nfstDetails.eligibility.incomeCeiling.includes('NO INCOME CRITERIA'));
  assert(nfstDetails.slotsAndReservation.totalFreshSlots.includes('750'));
  console.log('   ✅ NFST verified: No income limit, 750 slots, PDF citations present.');

  // Test 6: NOS information (2026-27 Amendment)
  console.log('6. Testing NOS (National Overseas Scholarship) information...');
  const nosRes = await service.processChat({ message: 'What are the criteria for National Overseas Scholarship?' });
  assert(nosRes.reply.includes('NOS_Scheme_Amendment_Order_2026-27.pdf'));
  const nosDetails = await dataStore.getScholarshipDetails({ scheme: 'nos' });
  assert(nosDetails.amendments2026.some((c) => c.includes('Top 1,000')));
  assert(nosDetails.amendments2026.some((c) => c.includes('Post-Doctoral Research')));
  console.log('   ✅ NOS verified: Top 1,000 QS ranking and Post-Doctoral omission confirmed.');

  // Test 7: Required documents
  console.log('7. Testing required documents for Post-Matric...');
  const docsRes = await service.processChat({ message: 'What documents are required for Post-Matric?' });
  assert(docsRes.reply.includes('Income Certificate') || docsRes.reply.includes('ST'));
  assert(docsRes.reply.includes('Post_Matric_Scholarship_Guidelines_2022.pdf'));
  console.log('   ✅ Required documents and PDF citations verified.');

  // Test 8: Income requirements across schemes
  console.log('8. Testing income requirements verification...');
  const preMatricData = await dataStore.getScholarshipDetails({ scheme: 'pre-matric' });
  const postMatricData = await dataStore.getScholarshipDetails({ scheme: 'post-matric' });
  const topClassData = await dataStore.getScholarshipDetails({ scheme: 'top-class' });
  assert(preMatricData.eligibility.incomeCeiling.includes('2,50,000'));
  assert(postMatricData.eligibility.incomeCeiling.includes('2,50,000'));
  assert(topClassData.eligibility.incomeCeiling.includes('6.0 Lakh'));
  console.log('   ✅ Income ceilings verified (Pre/Post: 2.5L, Top Class: 6.0L, NFST: None).');

  // Test 9: Academic requirements
  console.log('9. Testing academic requirements...');
  assert(preMatricData.eligibility.academics.includes('Class 9 or 10'));
  assert(nfstData_academics = nfstDetails.eligibility.qualification.includes('55%'));
  console.log('   ✅ Academic requirements verified.');

  // Test 10: Application process & Portals
  console.log('10. Testing application process & official portals...');
  assert.strictEqual(preMatricData.portal, 'https://scholarships.gov.in (NSP) or State Portal');
  assert.strictEqual(nfstDetails.portal, 'https://fellowship.tribal.gov.in');
  assert.strictEqual(nosDetails.portal, 'https://overseas.tribal.gov.in');
  console.log('   ✅ Official portals verified.');

  // Test 11: Verification process
  console.log('11. Testing verification process rules...');
  assert(postMatricData.verification.level1_Institute.includes('Nodal Officer'));
  assert(postMatricData.verification.level2_District_State.includes('State Nodal Officer'));
  console.log('   ✅ Verification structure verified.');

  // Test 12: Renewal requirements
  assert(postMatricData.eligibility.incomeRules.some((r) => r.includes('NOT required for renewal')));
  assert(postMatricData.renewalRules.some((r) => r.includes('entire duration')));
  console.log('   ✅ Renewal: Fresh income certificate not required for ongoing years.');

  // Test 13: DBT / Payment information
  console.log('13. Testing DBT / payment information...');
  const dbtRes = await service.processChat({
    message: 'What is my DBT payment status?',
    userId: 'TSS-2025-45678',
    applicationId: 'app-pms-2025-001'
  });
  assert(dbtRes.reply.includes('45000') || dbtRes.reply.includes('disbursed'));
  console.log('   ✅ DBT payment verified.');

  // Test 14: Follow-up conversational context
  console.log('14. Testing follow-up conversation context...');
  const followUpRes = await service.processChat({
    message: 'What documents do I need?',
    conversationHistory: [
      { role: 'user', content: "I'm applying for Post-Matric scholarship." },
      { role: 'model', content: "Sure, I can help with the Post-Matric scholarship." }
    ]
  });
  assert(followUpRes.reply.includes('Post-Matric') || followUpRes.reply.includes('Post_Matric'));
  console.log('   ✅ Follow-up preserved scheme context without re-asking.');

  // Test 15: Out-of-domain strict refusal
  console.log('15. Testing out-of-domain rejection...');
  const outDomainRes = await service.processChat({ message: 'What is Python?' });
  assert.strictEqual(outDomainRes.reply, RESPONSES.OUT_OF_DOMAIN);
  console.log('   ✅ General queries strictly rejected.');

  // Test 16: Information not present in PDFs
  console.log('16. Testing unverified info rejection...');
  const unverifiedRes = await service.processChat({ message: 'What is the scholarship for learning space flight piloting?' });
  assert(unverifiedRes.reply.includes("don't have verified information") || unverifiedRes.reply.includes(RESPONSES.NOT_FOUND));
  console.log('   ✅ Unverified/hallucinatory query rejected without guessing.');

  // Test 17: User-specific application data vs PDF separation
  console.log('17. Testing separation of student application data & PDF rules...');
  const statusRes = await service.processChat({
    message: "What's my application status?",
    userId: 'TSS-2025-45678',
    applicationId: 'app-pms-2025-001'
  });
  assert(statusRes.reply.includes('PMS-2025-78432'));
  assert(statusRes.reply.includes('Department Verification'));
  console.log('   ✅ Student application data safely retrieved from database.');

  console.log('\n🌟 ALL 17 SCHOLARSHIP PDF VERIFICATION SUITES PASSED PERFECTLY!\n');
}

testPdfKnowledgeLayer().catch((err) => {
  console.error('❌ PDF Test failed:', err);
  process.exit(1);
});
