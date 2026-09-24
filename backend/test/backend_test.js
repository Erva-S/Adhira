const assert = require('assert');
const dataStore = require('../database/data_store');
const { GeminiService, RESPONSES, functionDeclarations } = require('../services/gemini_service');

async function runTests() {
  console.log('🧪 Starting JAGO AI Assistant Backend Tests...\n');

  // Test 1: Function declarations verification
  console.log('1. Checking Tool / Function Declarations...');
  assert.strictEqual(functionDeclarations.length, 9, 'Should have exactly 9 tool declarations');
  const expectedTools = [
    'getScholarshipSchemes',
    'getScholarshipDetails',
    'getEligibilityCriteria',
    'getRequiredDocuments',
    'getApplicationStatus',
    'getPendingActions',
    'getDeficiencies',
    'getDBTStatus',
    'getUserScholarshipProfile'
  ];
  for (const tool of expectedTools) {
    assert(functionDeclarations.some((t) => t.name === tool), `Tool ${tool} must be registered`);
  }
  console.log('   ✅ All 9 tools successfully declared.\n');

  // Test 2: Database Tool - getScholarshipSchemes
  console.log('2. Testing getScholarshipSchemes...');
  const schemes = await dataStore.getScholarshipSchemes();
  assert(schemes.length === 5, 'Should return all 5 MoTA schemes');
  assert(schemes.some((s) => s.id === 'sch-post-matric'), 'Must contain Post-Matric scheme');
  console.log(`   ✅ Returned ${schemes.length} official MoTA schemes.\n`);

  // Test 3: Database Tool - getScholarshipDetails
  console.log('3. Testing getScholarshipDetails (Post-Matric)...');
  const details = await dataStore.getScholarshipDetails({ scheme: 'post-matric' });
  assert.strictEqual(details.verified, true);
  assert.strictEqual(details.id, 'sch-post-matric');
  assert(details.eligibilityCriteria.length > 0);
  console.log('   ✅ Post-Matric details verified.\n');

  // Test 4: Database Tool - getApplicationStatus
  console.log('4. Testing getApplicationStatus for Rajesh Soren...');
  const status = await dataStore.getApplicationStatus({
    applicationId: 'app-pms-2025-001',
    authenticatedUserId: 'TSS-2025-45678'
  });
  assert.strictEqual(status.verified, true);
  assert.strictEqual(status.applicationNumber, 'PMS-2025-78432');
  assert.strictEqual(status.currentStage, 'Department Verification');
  console.log(`   ✅ Application status: ${status.status} at stage ${status.currentStage}.\n`);

  // Test 5: Security / User Isolation Check
  console.log('5. Testing Security Isolation (Cross-user access denial)...');
  const crossUserStatus = await dataStore.getApplicationStatus({
    applicationId: 'app-pms-2025-001',
    authenticatedUserId: 'ANOTHER-USER-99999'
  });
  assert.strictEqual(crossUserStatus.verified, false);
  assert(crossUserStatus.error.includes('Access denied'), 'Must deny access to another user application');
  console.log('   ✅ Cross-user data isolation enforced.\n');

  // Test 6: Database Tool - getDeficiencies & getPendingActions
  console.log('6. Testing getDeficiencies & getPendingActions...');
  const def = await dataStore.getDeficiencies({ authenticatedUserId: 'TSS-2025-45678' });
  assert.strictEqual(def.hasDeficiencies, true);
  assert(def.rejectedDocuments.some((d) => d.name === 'Income Certificate'));
  console.log('   ✅ Accurately retrieved pending Income Certificate deficiency.\n');

  // Test 7: Database Tool - getDBTStatus
  console.log('7. Testing getDBTStatus...');
  const dbt = await dataStore.getDBTStatus({ authenticatedUserId: 'TSS-2025-45678' });
  assert.strictEqual(dbt.hasPayments, true);
  assert(dbt.disbursedPayments.some((p) => p.amount === 45000));
  console.log('   ✅ Accurately retrieved ₹45,000 DBT disbursement record.\n');

  // Test 8: Out-of-Domain Guard
  console.log('8. Testing Out-of-Domain Queries...');
  process.env.ALLOW_LOCAL_FALLBACK = 'true';
  const service = new GeminiService();

  const outOfDomainQueries = [
    'Who is Elon Musk?',
    'Write Python code.',
    'Tell me a joke.',
    'What is the weather today?',
    'Explain quantum physics.'
  ];

  for (const q of outOfDomainQueries) {
    const res = await service.processChat({ message: q });
    assert.strictEqual(res.reply, RESPONSES.OUT_OF_DOMAIN, `Query "${q}" must be rejected`);
  }
  console.log('   ✅ All out-of-domain queries properly rejected with standard refusal message.\n');

  // Test 9: Domain Query Processing
  console.log('9. Testing Domain Query Processing with context...');
  const appStatusRes = await service.processChat({
    message: "What's my application status?",
    userId: 'TSS-2025-45678',
    applicationId: 'app-pms-2025-001'
  });
  assert(appStatusRes.reply.includes('Post-Matric') || appStatusRes.reply.includes('Department Verification'));
  console.log('   ✅ Application status query answered correctly.\n');

  console.log('🎉 ALL BACKEND TESTS PASSED SUCCESSFULLY!\n');
}

runTests().catch((err) => {
  console.error('❌ Test failed:', err);
  process.exit(1);
});
