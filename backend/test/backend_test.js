const assert = require('assert');
const dataStore = require('../database/data_store');
const { GeminiService, RESPONSES, functionDeclarations } = require('../services/gemini_service');
const websiteScraperService = require('../services/website_scraper_service');

async function runTests() {
  console.log('🧪 Starting JAGO AI Assistant Backend Tests...\n');

  // Test 1: Function declarations verification
  console.log('1. Checking Tool / Function Declarations...');
  assert.strictEqual(functionDeclarations.length, 10, 'Should have exactly 10 tool declarations');
  const expectedTools = [
    'getScholarshipSchemes',
    'getScholarshipDetails',
    'getEligibilityCriteria',
    'getRequiredDocuments',
    'getApplicationStatus',
    'getPendingActions',
    'getDeficiencies',
    'getDBTStatus',
    'getUserScholarshipProfile',
    'getOfficialWebsiteKnowledge'
  ];
  for (const tool of expectedTools) {
    assert(functionDeclarations.some((t) => t.name === tool), `Tool ${tool} must be registered`);
  }
  console.log('   ✅ All 10 tools successfully declared.\n');

  // Test 2: Website Scraper Service Whitelist & Knowledge Retrieval
  console.log('2. Testing Website Scraper Service & Security Whitelist...');
  assert.strictEqual(websiteScraperService.isTrustedUrl('https://tribal.nic.in/ScholarshiP.aspx'), true);
  assert.strictEqual(websiteScraperService.isTrustedUrl('https://dbttribal.gov.in/'), true);
  assert.strictEqual(websiteScraperService.isTrustedUrl('https://malicious-site.com/steal'), false);
  assert.strictEqual(websiteScraperService.isTrustedUrl('https://google.com'), false);

  const knowledge = await websiteScraperService.getKnowledge();
  assert(knowledge.schemes.preMatric, 'Must contain Pre-Matric scheme');
  assert(knowledge.schemes.postMatric, 'Must contain Post-Matric scheme');
  assert(knowledge.schemes.topClass, 'Must contain Top Class scheme');
  assert(knowledge.schemes.nfst, 'Must contain NFST fellowship');
  assert(knowledge.schemes.nos, 'Must contain NOS overseas scheme');
  assert(knowledge.deadlines.length > 0, 'Must contain deadlines/extension circulars');
  console.log('   ✅ Website scraper whitelist and structured extraction verified.\n');

  // Test 3: Database Tool - getScholarshipSchemes
  console.log('3. Testing getScholarshipSchemes...');
  const schemes = await dataStore.getScholarshipSchemes();
  assert(schemes.length === 5, 'Should return all 5 MoTA schemes');
  assert(schemes.some((s) => s.id === 'sch-post-matric'), 'Must contain Post-Matric scheme');
  console.log(`   ✅ Returned ${schemes.length} official MoTA schemes.\n`);

  // Test 4: Database Tool - getScholarshipDetails
  console.log('4. Testing getScholarshipDetails (Post-Matric)...');
  const details = await dataStore.getScholarshipDetails({ scheme: 'post-matric' });
  assert.strictEqual(details.verified, true);
  assert.strictEqual(details.id, 'sch-post-matric');
  assert(details.eligibilityCriteria.length > 0);
  console.log('   ✅ Post-Matric details verified.\n');

  // Test 5: Database Tool - getApplicationStatus
  console.log('5. Testing getApplicationStatus for Rajesh Soren...');
  const status = await dataStore.getApplicationStatus({
    applicationId: 'app-pms-2025-001',
    authenticatedUserId: 'TSS-2025-45678'
  });
  assert.strictEqual(status.verified, true);
  assert.strictEqual(status.applicationNumber, 'PMS-2025-78432');
  assert.strictEqual(status.currentStage, 'Department Verification');
  console.log(`   ✅ Application status: ${status.status} at stage ${status.currentStage}.\n`);

  // Test 6: Security / User Isolation Check
  console.log('6. Testing Security Isolation (Cross-user access denial)...');
  const crossUserStatus = await dataStore.getApplicationStatus({
    applicationId: 'app-pms-2025-001',
    authenticatedUserId: 'ANOTHER-USER-99999'
  });
  assert.strictEqual(crossUserStatus.verified, false);
  assert(crossUserStatus.error.includes('Access denied'), 'Must deny access to another user application');
  console.log('   ✅ Cross-user data isolation enforced.\n');

  // Test 7: Database Tool - getDeficiencies & getPendingActions
  console.log('7. Testing getDeficiencies & getPendingActions...');
  const def = await dataStore.getDeficiencies({ authenticatedUserId: 'TSS-2025-45678' });
  assert.strictEqual(def.hasDeficiencies, true);
  assert(def.rejectedDocuments.some((d) => d.name === 'Income Certificate'));
  console.log('   ✅ Accurately retrieved pending Income Certificate deficiency.\n');

  // Test 8: Database Tool - getDBTStatus
  console.log('8. Testing getDBTStatus...');
  const dbt = await dataStore.getDBTStatus({ authenticatedUserId: 'TSS-2025-45678' });
  assert.strictEqual(dbt.hasPayments, true);
  assert(dbt.disbursedPayments.some((p) => p.amount === 45000));
  console.log('   ✅ Accurately retrieved ₹45,000 DBT disbursement record.\n');

  // Test 9: Testing the 10 User-Specified Questions
  console.log('9. Testing the 10 User-Specified Questions from prompt...\n');
  process.env.ALLOW_LOCAL_FALLBACK = 'true';
  const service = new GeminiService();

  // Q1: What scholarships are available?
  const q1 = await service.processChat({ message: 'What scholarships are available?' });
  assert(q1.reply.includes('Pre-Matric') && q1.reply.includes('Post-Matric') && q1.reply.includes('Top Class'));
  assert(q1.reply.includes('Source: Official Scholarship Website'), 'Q1 must cite official source');
  console.log('   ✅ Q1 ("What scholarships are available?") -> Verified with official portal citation');

  // Q2: What documents do I need?
  const q2 = await service.processChat({ message: 'What documents do I need?' });
  assert(q2.reply.includes('Aadhaar') && q2.reply.includes('Income Certificate'));
  assert(q2.reply.includes('Source: Official Scholarship Website'), 'Q2 must cite official source');
  console.log('   ✅ Q2 ("What documents do I need?") -> Verified with official portal citation');

  // Q3: What is the latest deadline?
  const q3 = await service.processChat({ message: 'What is the latest deadline?' });
  assert(q3.reply.includes('Deadline') || q3.reply.includes('extended') || q3.reply.includes('National Scholarship Portal'));
  assert(q3.reply.includes('Source: Official Scholarship Website'), 'Q3 must cite official source');
  console.log('   ✅ Q3 ("What is the latest deadline?") -> Verified with official portal citation');

  // Q4: Has the deadline changed?
  const q4 = await service.processChat({ message: 'Has the deadline changed?' });
  assert(q4.reply.includes('extension') || q4.reply.includes('extended'));
  assert(q4.reply.includes('Source: Official Scholarship Website'), 'Q4 must cite official source');
  console.log('   ✅ Q4 ("Has the deadline changed?") -> Verified with official portal citation');

  // Q5: What are the eligibility criteria?
  const q5 = await service.processChat({ message: 'What are the eligibility criteria?' });
  assert(q5.reply.includes('2.50 Lakh') && q5.reply.includes('Pre-Matric') && q5.reply.includes('Top Class'));
  assert(q5.reply.includes('Source: Official Scholarship Website'), 'Q5 must cite official source');
  console.log('   ✅ Q5 ("What are the eligibility criteria?") -> Verified with official portal citation');

  // Q6: Am I eligible based on my profile? & Check my eligibility
  const q6 = await service.processChat({
    message: 'Am I eligible based on my profile?',
    userId: 'TSS-2025-45678',
    applicationId: 'app-pms-2025-001'
  });
  assert(q6.reply.includes('Rajesh Soren') && q6.reply.includes('Post-Matric') && q6.reply.includes('Top Class'));
  assert(q6.reply.includes('Source: Official Scholarship Website'), 'Q6 must cite official source');

  const q6b = await service.processChat({
    message: 'Check my eligibility',
    userId: 'TSS-2025-45678',
    applicationId: 'app-pms-2025-001'
  });
  assert(q6b.reply.includes('Rajesh Soren') && q6b.reply.includes('Eligible'));
  console.log('   ✅ Q6 ("Check my eligibility" / "Am I eligible?") -> Verified automatic profile self-evaluation');

  // Q7: What is DBT?
  const q7 = await service.processChat({ message: 'What is DBT?' });
  assert(q7.reply.includes('Direct Benefit Transfer') && q7.reply.includes('PFMS') && q7.reply.includes('Aadhaar'));
  assert(q7.reply.includes('Source: Official Scholarship Website'), 'Q7 must cite official source');
  console.log('   ✅ Q7 ("What is DBT?") -> Verified DBT concept with official portal citation');

  // Q8: What is my application status?
  const q8 = await service.processChat({
    message: 'What is my application status?',
    userId: 'TSS-2025-45678',
    applicationId: 'app-pms-2025-001'
  });
  assert(q8.reply.includes('PMS-2025-78432') && q8.reply.includes('Department Verification'));
  assert(!q8.reply.includes('Source: Official Scholarship Website'), 'Q8 is private app data, must not cite web');
  console.log('   ✅ Q8 ("What is my application status?") -> Uses Adhira local application data (NO web scrape)');

  // Q9: Why is my application pending?
  const q9 = await service.processChat({
    message: 'Why is my application pending?',
    userId: 'TSS-2025-45678',
    applicationId: 'app-pms-2025-001'
  });
  assert(q9.reply.includes('Income Certificate') && q9.reply.includes('pending'));
  assert(!q9.reply.includes('Source: Official Scholarship Website'), 'Q9 is private app data, must not cite web');
  console.log('   ✅ Q9 ("Why is my application pending?") -> Uses Adhira local deficiencies data (NO web scrape)');

  // Q10: Unrelated queries
  const q10a = await service.processChat({ message: 'What is the capital of France?' });
  assert.strictEqual(q10a.reply, RESPONSES.OUT_OF_DOMAIN);
  const q10b = await service.processChat({ message: 'Who is Elon Musk?' });
  assert.strictEqual(q10b.reply, RESPONSES.OUT_OF_DOMAIN);
  const q10c = await service.processChat({ message: 'Write Python code for me' });
  assert.strictEqual(q10c.reply, RESPONSES.OUT_OF_DOMAIN);
  console.log('   ✅ Q10 (Unrelated queries) -> Strictly blocked by out-of-domain guard\n');

  console.log('🎉 ALL 10 TESTS AND QUESTIONS PASSED SUCCESSFULLY!\n');
}

runTests().catch((err) => {
  console.error('❌ Test failed:', err);
  process.exit(1);
});
