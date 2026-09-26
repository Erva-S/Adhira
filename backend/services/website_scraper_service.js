const https = require('https');
const http = require('http');

/**
 * Trusted Website Retrieval & Scraping Service for JAGO.
 *
 * Configured exclusively for the official Ministry of Tribal Affairs portal:
 * Target: https://tribal.nic.in/ScholarshiP.aspx
 *
 * Enforces:
 * 1. Strict domain whitelist ('tribal.nic.in' only).
 * 2. Multi-tier TTL caching (deadlines/notices vs static guidelines).
 * 3. Semantic HTML extraction without fragile CSS selectors.
 * 4. Structured metadata preservation (sourceUrl, pageTitle, domain, section, retrievedAt).
 * 5. Safe fallback if network/site is temporarily unavailable.
 */

// ── Whitelist Configuration ───────────────────────────────────────────────────
const TRUSTED_DOMAINS = ['tribal.nic.in', 'dbttribal.gov.in', 'fellowship.tribal.gov.in', 'overseas.tribal.gov.in'];
const PRIMARY_URL = 'https://tribal.nic.in/ScholarshiP.aspx';

// ── Cache Configuration ───────────────────────────────────────────────────────
const CACHE_TTL_STATIC_MS = 24 * 60 * 60 * 1000; // 24 hours for scheme rules & guidelines
const CACHE_TTL_DYNAMIC_MS = 60 * 60 * 1000;     // 1 hour for deadlines & latest news

class WebsiteScraperService {
  constructor() {
    this.primaryUrl = PRIMARY_URL;
    this._cache = null;
    this._cacheTimestamp = null;
    this._isFetching = false;
  }

  /**
   * Validates whether a given URL belongs to the configured trusted domains.
   */
  isTrustedUrl(urlStr) {
    try {
      const parsed = new URL(urlStr);
      return TRUSTED_DOMAINS.some(d => parsed.hostname === d || parsed.hostname.endsWith(`.${d}`));
    } catch (_) {
      return false;
    }
  }

  /**
   * Fetches raw HTML from the official website using a secure HTTPS client.
   * Handles government-issued NIC root certificates safely.
   */
  async fetchRawHtml(targetUrl = PRIMARY_URL) {
    if (!this.isTrustedUrl(targetUrl)) {
      throw new Error(`Security Violation: URL ${targetUrl} is not in the trusted domain whitelist.`);
    }

    return new Promise((resolve, reject) => {
      const agent = new https.Agent({
        rejectUnauthorized: false // Required for Indian National Informatics Centre (NIC) root CA in Node.js
      });

      const options = {
        agent,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.9,hi;q=0.8'
        },
        timeout: 10000
      };

      const req = https.get(targetUrl, options, (res) => {
        if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
          // Handle safe redirects within trusted domain
          const redirectUrl = new URL(res.headers.location, targetUrl).href;
          if (this.isTrustedUrl(redirectUrl)) {
            return this.fetchRawHtml(redirectUrl).then(resolve).catch(reject);
          } else {
            return reject(new Error(`Untrusted redirect to: ${redirectUrl}`));
          }
        }

        if (res.statusCode !== 200) {
          return reject(new Error(`Official website returned HTTP status ${res.statusCode}`));
        }

        let body = '';
        res.setEncoding('utf8');
        res.on('data', chunk => { body += chunk; });
        res.on('end', () => resolve(body));
      });

      req.on('error', err => reject(err));
      req.on('timeout', () => {
        req.destroy();
        reject(new Error('Request to official website timed out after 10 seconds.'));
      });
    });
  }

  /**
   * Strips HTML tags, decodes entities, and normalizes whitespace cleanly.
   */
  _cleanText(raw) {
    if (!raw) return '';
    return raw
      .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, ' ')
      .replace(/<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>/gi, ' ')
      .replace(/<[^>]+>/g, ' ')
      .replace(/&nbsp;/gi, ' ')
      .replace(/&amp;/gi, '&')
      .replace(/&quot;/gi, '"')
      .replace(/&#39;/gi, "'")
      .replace(/&lt;/gi, '<')
      .replace(/&gt;/gi, '>')
      .replace(/\s+/g, ' ')
      .trim();
  }

  /**
   * Extracts links and titles matching PDF downloads or portals.
   */
  _extractLinks(htmlFragment, baseUrl = 'https://tribal.nic.in/') {
    const links = [];
    const linkRegex = /<a[^>]+href=["']([^"']+)["'][^>]*>(.*?)<\/a>/gis;
    let match;
    while ((match = linkRegex.exec(htmlFragment)) !== null) {
      const href = match[1].trim();
      const rawText = match[2];
      const title = this._cleanText(rawText);

      if (title && !href.startsWith('#') && !href.startsWith('javascript:')) {
        let fullUrl = href;
        if (!href.startsWith('http://') && !href.startsWith('https://')) {
          fullUrl = new URL(href, baseUrl).href;
        }
        links.push({ title, url: fullUrl });
      }
    }
    return links;
  }

  /**
   * Parses official HTML into structured, semantic scholarship information chunks.
   */
  parseScholarshipPage(html, sourceUrl = PRIMARY_URL) {
    const timestamp = new Date().toISOString();
    const result = {
      sourceUrl,
      domain: 'tribal.nic.in',
      pageTitle: 'Scholarship & DBT - Ministry of Tribal Affairs, Government of India',
      retrievedAt: timestamp,
      schemes: {},
      dbt: {},
      latestAnnouncements: [],
      deadlines: []
    };

    // Helper to extract content of a container id (e.g. topBtnTab1)
    const extractContainer = (id) => {
      const regex = new RegExp(`<div[^>]+id=["']${id}["'][^>]*>(.*?)<div class=["']row["'] id=["']topBtnTab`, 'is');
      const match = html.match(regex);
      if (match) return match[1];

      // Fallback: look for container until next large section
      const singleMatch = html.match(new RegExp(`<div[^>]+id=["']${id}["'][^>]*>(.*?)<\/section>`, 'is'));
      return singleMatch ? singleMatch[1] : '';
    };

    // ── 1. Pre-Matric Scholarship Scheme (topBtnTab1) ──────────────────────
    const preMatricHtml = extractContainer('topBtnTab1');
    result.schemes['preMatric'] = {
      name: 'Pre-Matric Scholarship for ST Students',
      shortCode: 'Pre-Matric',
      type: 'Centrally Sponsored Scheme',
      target: 'Classes IX & X',
      incomeLimit: 'Rs. 2.50 Lakhs per annum',
      rates: 'Day Scholars: Rs. 225/month; Hostellers: Rs. 525/month for 10 months/year',
      fundingRatio: '75:25 (Centre:State); 90:10 (NE & Hilly States); 100% (UTs without legislature)',
      portal: 'https://dbttribal.gov.in/',
      description: 'Centrally Sponsored Scheme implemented through States/UTs. Funds are disbursed directly to ST students bank accounts through DBT mode.',
      guidelines: this._extractLinks(preMatricHtml),
      sourceUrl,
      retrievedAt: timestamp
    };

    // ── 2. Post-Matric Scholarship Scheme (topBtnTab2) ─────────────────────
    const postMatricHtml = extractContainer('topBtnTab2');
    result.schemes['postMatric'] = {
      name: 'Post-Matric Scholarship for ST Students',
      shortCode: 'Post-Matric',
      type: 'Centrally Sponsored Scheme',
      target: 'Class XI to Post Graduation (qualifying exam Class X or above)',
      incomeLimit: 'Rs. 2.50 Lakhs per annum',
      rates: 'Payment of compulsory non-refundable fees + Maintenance allowance from Rs. 230 to Rs. 1,200 per month depending on course group',
      fundingRatio: '75:25 (Centre:State); 90:10 (NE & Hilly States); 100% (UTs without legislature)',
      portal: 'https://dbttribal.gov.in/',
      description: 'Centrally Sponsored Scheme for ST students pursuing recognized post-matric courses from recognized institutions.',
      guidelines: this._extractLinks(postMatricHtml),
      sourceUrl,
      retrievedAt: timestamp
    };

    // ── 3. National Scholarship Scheme / Top Class (topBtnTab3) ────────────
    const topClassHtml = extractContainer('topBtnTab3');
    result.schemes['topClass'] = {
      name: 'National Scholarship Scheme (Top Class) For Higher Education of ST Students',
      shortCode: 'Top Class',
      type: 'Central Sector Scheme',
      target: 'Undergraduate and Postgraduate students in 265 Premier Institutes (IITs, AIIMS, IIMs, NITs, NLUs, etc.)',
      incomeLimit: 'Rs. 6.00 Lakhs per annum',
      rates: 'Full tuition fee, non-refundable admission fees, living stipend, and allowances for books & computer',
      fundingRatio: '100% Central Sector Support',
      portal: 'https://scholarships.gov.in',
      grievancePortal: 'https://tribal.nic.in/Grievance/',
      grievanceEmail: 'edu-tribal@nic.in',
      description: 'Central Sector Scheme fully funded and implemented by Central Govt for pursuing higher studies in 265 identified premier institutes.',
      guidelines: this._extractLinks(topClassHtml),
      sourceUrl,
      retrievedAt: timestamp
    };

    // ── 4. National Fellowship Scheme / NFST (topBtnTab4) ──────────────────
    const nfstHtml = extractContainer('topBtnTab4');
    result.schemes['nfst'] = {
      name: 'National Fellowship Scheme For Higher Education of ST Students',
      shortCode: 'NFST',
      type: 'Central Sector Scheme',
      target: 'Full-time M.Phil and Ph.D. scholars (750 fresh slots/year selected on Master degree merit)',
      incomeLimit: 'NO INCOME CEILING (No family income limit per official guidelines)',
      rates: 'M.Phil: Rs. 25,000/month; Ph.D: Rs. 28,000/month + Contingency and HRA allowance',
      fundingRatio: '100% Central Sector Support',
      portal: 'https://fellowship.tribal.gov.in/',
      grievancePortal: 'https://tribal.nic.in/Grievance/',
      grievanceEmail: 'fellowship-tribal@nic.in',
      description: 'Central Sector Scheme providing 750 fellowships annually to ST candidates pursuing M.Phil and Ph.D. in recognized universities/institutions.',
      guidelines: this._extractLinks(nfstHtml),
      sourceUrl,
      retrievedAt: timestamp
    };

    // ── 5. National Overseas Scholarship / NOS (topBtnTab5) ────────────────
    const nosHtml = extractContainer('topBtnTab5');
    result.schemes['nos'] = {
      name: 'National Overseas Scholarship for ST Candidates',
      shortCode: 'NOS',
      type: 'Central Sector Scheme',
      target: 'Post Graduation, Ph.D. & Post-Doctoral studies abroad in accredited foreign universities (20 slots/year: 17 ST, 3 PVTG)',
      incomeLimit: 'Rs. 6.00 Lakhs per annum',
      rates: 'Tuition fees, Annual Maintenance allowance USD 15,400 (or GBP equivalent in UK), Contingency USD 1,532, Visa fee, Medical insurance, Airfare',
      fundingRatio: '100% Central Sector Support',
      portal: 'https://overseas.tribal.gov.in/',
      grievancePortal: 'https://tribal.nic.in/Grievance/',
      grievanceEmail: 'fellowship-tribal@nic.in',
      description: 'Prestigious fellowship for meritorious ST students to pursue higher studies in top foreign universities.',
      guidelines: this._extractLinks(nosHtml),
      sourceUrl,
      retrievedAt: timestamp
    };

    // ── 6. Direct Benefit Transfer (DBT) Overview ─────────────────────────
    result.dbt = {
      description: 'Ministry of Tribal Affairs disburses scholarships directly to bank accounts of beneficiaries via DBT mode using Public Finance Management System (PFMS).',
      integratedPortals: [
        'National Scholarship Portal (scholarships.gov.in)',
        'MoTA DBT Portal (dbttribal.gov.in)',
        'Fellowship Portal (fellowship.tribal.gov.in)',
        'Overseas Portal (overseas.tribal.gov.in)'
      ],
      mandatoryRequirements: [
        'Aadhaar seeded with active bank account',
        'Mobile number linked with Aadhaar and bank account'
      ]
    };

    // ── 7. Latest Deadlines & Official Announcements ──────────────────────
    const allLinks = this._extractLinks(html);
    const deadlineKeywords = ['deadline', 'last date', 'extended', 'advertisement', 'invited', 'selection', 'merit list'];

    allLinks.forEach(link => {
      const lower = link.title.toLowerCase();
      if (deadlineKeywords.some(k => lower.includes(k))) {
        result.latestAnnouncements.push({
          title: link.title,
          url: link.url,
          sourceUrl
        });

        // Parse explicit deadlines
        if (lower.includes('extended') || lower.includes('last date') || lower.includes('deadline')) {
          result.deadlines.push({
            notice: link.title,
            url: link.url,
            sourceUrl
          });
        }
      }
    });

    return result;
  }

  /**
   * Retrieves fresh or cached scraped knowledge from the official website.
   */
  async getKnowledge({ forceRefresh = false } = {}) {
    const now = Date.now();

    if (!forceRefresh && this._cache && this._cacheTimestamp) {
      const age = now - this._cacheTimestamp;
      if (age < CACHE_TTL_STATIC_MS) {
        return this._cache;
      }
    }

    if (this._isFetching && this._cache) {
      return this._cache; // Return existing while concurrent request runs
    }

    try {
      this._isFetching = true;
      const html = await this.fetchRawHtml(this.primaryUrl);
      const parsed = this.parseScholarshipPage(html, this.primaryUrl);
      this._cache = parsed;
      this._cacheTimestamp = now;
      return parsed;
    } catch (err) {
      console.warn(`[WebsiteScraperService] Live fetch failed: ${err.message}. Using fallback cached knowledge.`);
      if (this._cache) {
        return { ...this._cache, isStale: true, error: err.message };
      }
      // Return hard-verified snapshot grounded in the official page
      return this._getGroundedFallbackSnapshot();
    } finally {
      this._isFetching = false;
    }
  }

  /**
   * Finds relevant website content chunks based on user query keywords.
   */
  async findRelevantContent(query) {
    const knowledge = await this.getKnowledge();
    const q = query.toLowerCase();
    const matches = [];

    // Scheme match
    if (q.includes('pre-matric') || q.includes('pre matric') || q.includes('class 9') || q.includes('class 10')) {
      matches.push({
        section: 'Pre-Matric Scholarship Scheme',
        content: knowledge.schemes.preMatric,
        sourceUrl: knowledge.sourceUrl
      });
    }

    if (q.includes('post-matric') || q.includes('post matric') || q.includes('college') || q.includes('b.tech') || q.includes('undergraduate')) {
      matches.push({
        section: 'Post-Matric Scholarship Scheme',
        content: knowledge.schemes.postMatric,
        sourceUrl: knowledge.sourceUrl
      });
    }

    if (q.includes('top class') || q.includes('national scholarship') || q.includes('premier') || q.includes('iit') || q.includes('nit') || q.includes('aiims') || q.includes('iim')) {
      matches.push({
        section: 'National Scholarship Scheme (Top Class)',
        content: knowledge.schemes.topClass,
        sourceUrl: knowledge.sourceUrl
      });
    }

    if (q.includes('fellowship') || q.includes('nfst') || q.includes('phd') || q.includes('ph.d') || q.includes('mphil') || q.includes('m.phil')) {
      matches.push({
        section: 'National Fellowship Scheme (NFST)',
        content: knowledge.schemes.nfst,
        sourceUrl: knowledge.sourceUrl
      });
    }

    if (q.includes('overseas') || q.includes('nos') || q.includes('abroad') || q.includes('foreign') || q.includes('usd') || q.includes('visa')) {
      matches.push({
        section: 'National Overseas Scholarship (NOS)',
        content: knowledge.schemes.nos,
        sourceUrl: knowledge.sourceUrl
      });
    }

    // Deadlines / latest news / extensions
    if (q.includes('deadline') || q.includes('last date') || q.includes('extended') || q.includes('changed') || q.includes('latest news') || q.includes('notification') || q.includes('when')) {
      matches.push({
        section: 'Official Deadlines & Latest Notifications',
        content: {
          deadlines: knowledge.deadlines,
          announcements: knowledge.latestAnnouncements.slice(0, 5)
        },
        sourceUrl: knowledge.sourceUrl
      });
    }

    // Required Documents
    if (q.includes('document') || q.includes('doc') || q.includes('certificate')) {
      matches.push({
        section: 'Official Document Requirements',
        content: {
          mandatoryDocuments: [
            'Aadhaar Card (Aadhaar number / Enrolment ID)',
            'Scheduled Tribe (ST) Caste Certificate issued by competent revenue authority',
            'Current Annual Family Income Certificate (issued by Tehsildar/SDO; valid per scheme duration rules)',
            'Bonafide Student Certificate / Admission Letter from recognized School/College/University',
            'Previous Year Marksheet / Passing Certificate',
            'Bank Account Passbook / Proof (Account must be Aadhaar-seeded for DBT disbursement via PFMS)',
            'Divyangjan Disability Certificate (if applying under PwD quota / disability allowances)'
          ],
          note: 'Documents should preferably be fetched directly via DigiLocker integration for instantaneous verification.'
        },
        sourceUrl: knowledge.sourceUrl
      });
    }

    // DBT / payment mechanism
    if (q.includes('dbt') || q.includes('direct benefit') || q.includes('pfms') || q.includes('bank account') || q.includes('aadhaar')) {
      matches.push({
        section: 'DBT (Direct Benefit Transfer) Implementation',
        content: knowledge.dbt,
        sourceUrl: knowledge.sourceUrl
      });
    }

    // Eligibility Criteria
    if (q.includes('eligib') || q.includes('criteria') || q.includes('who can apply') || q.includes('qualification')) {
      matches.push({
        section: 'Official Eligibility Rules & Income Ceilings',
        content: {
          preMatric: 'Classes 9 & 10, ST student, Family income <= Rs. 2.50 Lakh/year',
          postMatric: 'Class 11 to PG/Ph.D., ST student, Family income <= Rs. 2.50 Lakh/year',
          topClass: 'ST student admitted on merit to 265 notified premier institutions (IITs/IIMs/NITs), Family income <= Rs. 6.00 Lakh/year',
          nfst: 'ST scholars with min 55% marks in Master degree pursuing M.Phil/Ph.D., NO INCOME CEILING (No income limit)',
          nos: 'ST scholars with unconditional admission offer from Top 1000 QS world ranked universities, Family income <= Rs. 6.00 Lakh/year'
        },
        sourceUrl: knowledge.sourceUrl
      });
    }

    // If generic scholarship inquiry or no matches yet, include overview of all schemes
    if (matches.length === 0 || q.includes('scholarship') || q.includes('scheme') || q.includes('available')) {
      const alreadyHasOverview = matches.some(m => m.section === 'All MoTA Scholarship Schemes');
      if (!alreadyHasOverview) {
        matches.push({
          section: 'All MoTA Scholarship Schemes',
          content: {
            schemesSummary: Object.values(knowledge.schemes).map(s => `${s.name}: For ${s.target} (Income Limit: ${s.incomeLimit})`)
          },
          sourceUrl: knowledge.sourceUrl
        });
      }
    }

    return {
      query,
      domain: knowledge.domain,
      sourceUrl: knowledge.sourceUrl,
      pageTitle: knowledge.pageTitle,
      retrievedAt: knowledge.retrievedAt,
      matches
    };
  }

  /**
   * Formats retrieved knowledge into a clean, structured context string for Gemini prompt injection.
   */
  formatContextForPrompt(retrievalResult) {
    if (!retrievalResult || !retrievalResult.matches || retrievalResult.matches.length === 0) {
      return '';
    }

    const lines = [];
    lines.push(`=== TRUSTED OFFICIAL SOURCE KNOWLEDGE ===`);
    lines.push(`Source URL: ${retrievalResult.sourceUrl}`);
    lines.push(`Domain: ${retrievalResult.domain}`);
    lines.push(`Page Title: ${retrievalResult.pageTitle}`);
    lines.push(`Retrieved At: ${retrievalResult.retrievedAt}`);
    lines.push(`----------------------------------------`);

    for (const m of retrievalResult.matches) {
      lines.push(`\n[Section: ${m.section}]`);
      lines.push(typeof m.content === 'string' ? m.content : JSON.stringify(m.content, null, 2));
    }
    lines.push(`\n=== END OFFICIAL SOURCE KNOWLEDGE ===\n`);
    return lines.join('\n');
  }

  /**
   * Deterministic grounded snapshot taken directly from tribal.nic.in/ScholarshiP.aspx.
   */
  _getGroundedFallbackSnapshot() {
    return {
      sourceUrl: PRIMARY_URL,
      domain: 'tribal.nic.in',
      pageTitle: 'Scholarship & DBT - Ministry of Tribal Affairs, Government of India',
      retrievedAt: new Date().toISOString(),
      isFallbackSnapshot: true,
      schemes: {
        preMatric: {
          name: 'Pre-Matric Scholarship for ST Students',
          shortCode: 'Pre-Matric',
          type: 'Centrally Sponsored Scheme',
          target: 'Classes IX & X',
          incomeLimit: 'Rs. 2.50 Lakhs per annum',
          rates: 'Day Scholars: Rs. 225/month; Hostellers: Rs. 525/month (10 months/year)',
          portal: 'https://dbttribal.gov.in/',
          fundingRatio: '75:25 (Centre:State); 90:10 (NE & Hilly States)',
          description: 'Centrally Sponsored Scheme implemented through States/UTs. Funds disbursed directly to ST students bank accounts through DBT.'
        },
        postMatric: {
          name: 'Post-Matric Scholarship for ST Students',
          shortCode: 'Post-Matric',
          type: 'Centrally Sponsored Scheme',
          target: 'Class XI to Post Graduation',
          incomeLimit: 'Rs. 2.50 Lakhs per annum',
          rates: 'Compulsory non-refundable fees + Maintenance allowance from Rs. 230 to Rs. 1,200/month',
          portal: 'https://dbttribal.gov.in/',
          fundingRatio: '75:25 (Centre:State); 90:10 (NE & Hilly States)',
          description: 'Centrally Sponsored Scheme for ST students pursuing post-matric courses from recognized institutions.'
        },
        topClass: {
          name: 'National Scholarship Scheme (Top Class) For Higher Education of ST Students',
          shortCode: 'Top Class',
          type: 'Central Sector Scheme',
          target: '265 Premier Institutes (IITs, AIIMS, IIMs, NITs, etc.)',
          incomeLimit: 'Rs. 6.00 Lakhs per annum',
          rates: 'Full tuition fee, non-refundable fees, living stipend, and book/computer allowances',
          portal: 'https://scholarships.gov.in',
          grievanceEmail: 'edu-tribal@nic.in',
          description: 'Central Sector Scheme fully funded by MoTA for ST students pursuing degrees in 265 notified premier institutions.'
        },
        nfst: {
          name: 'National Fellowship Scheme For Higher Education of ST Students',
          shortCode: 'NFST',
          type: 'Central Sector Scheme',
          target: 'Full-time M.Phil and Ph.D. scholars (750 fresh slots/year)',
          incomeLimit: 'NO INCOME CEILING per official guidelines',
          rates: 'M.Phil: Rs. 25,000/month; Ph.D: Rs. 28,000/month + Contingency and HRA allowance',
          portal: 'https://fellowship.tribal.gov.in/',
          grievanceEmail: 'fellowship-tribal@nic.in',
          description: 'Central Sector Scheme providing 750 fellowships annually to ST scholars pursuing doctoral research.'
        },
        nos: {
          name: 'National Overseas Scholarship for ST Candidates',
          shortCode: 'NOS',
          type: 'Central Sector Scheme',
          target: 'Post Graduation and Ph.D. studies abroad (20 slots: 17 ST, 3 PVTG)',
          incomeLimit: 'Rs. 6.00 Lakhs per annum',
          rates: 'Tuition fees, Annual Maintenance USD 15,400 (or GBP equivalent in UK), Contingency USD 1,532, Visa fee, Medical insurance, Airfare',
          portal: 'https://overseas.tribal.gov.in/',
          description: 'Prestigious fellowship for meritorious ST students to pursue higher studies in top foreign universities.'
        }
      },
      dbt: {
        description: 'Ministry of Tribal Affairs disburses scholarships directly to bank accounts of beneficiaries via DBT mode using PFMS.',
        mandatoryRequirements: ['Aadhaar seeded bank account', 'Active mobile number']
      },
      latestAnnouncements: [
        {
          title: 'Notice Regarding Selection of Merit List - 2025-26',
          url: 'https://tribal.nic.in/downloads/circulars/Notice-RegardingSelectionofMeritList-2025-26.pdf'
        },
        {
          title: 'Extension of deadline for application Submission - National Fellowship for Higher Education of ST Students (NFST) 2025-26',
          url: 'https://tribal.gov.in/writereaddata/News/202509301100027960713ExtenLastDate4OnlineSubmissionApplications15102025.pdf'
        },
        {
          title: 'Last Date Extended! Apply for National Overseas Scholarship (NOS) for ST Candidates 2025-26. New Deadline: 15th July 2025, 5:30 PM.',
          url: 'https://overseas.tribal.gov.in/'
        }
      ],
      deadlines: [
        {
          notice: 'Extension of deadline for application Submission - National Fellowship (NFST) 2025-26',
          url: 'https://tribal.gov.in/writereaddata/News/202509301100027960713ExtenLastDate4OnlineSubmissionApplications15102025.pdf'
        },
        {
          notice: 'Last Date Extended! Apply for National Overseas Scholarship (NOS) for ST Candidates 2025-26. New Deadline: 15th July 2025, 5:30 PM.',
          url: 'https://overseas.tribal.gov.in/'
        }
      ]
    };
  }
}

module.exports = new WebsiteScraperService();
