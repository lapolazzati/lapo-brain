# Ideas Backlog

_Random insights, tools, and patterns worth remembering. Not urgent, just interesting._

---

## Email Infrastructure Cost Optimization

**Source:** [@levelsio tweet](https://x.com/levelsio/status/2053482525780008997) - May 10, 2026

**Context:** Email sending service pricing comparison for 1M monthly emails:
- Postmark: $1,206/mo
- Resend: $650/mo
- SendGrid: $600/mo
- Cloudflare: $354/mo
- **Amazon SES: $100/mo** (cheapest)

**Insight:** Massive price variance for identical service (12x difference between Postmark and SES).

**Potential applications:**
- Catone email notifications (verifiche results, document requests)
- CEG outreach campaigns (Milano contractors, future prospects)
- Klaaryo client outreach infrastructure
- Any product requiring transactional email at scale

**Action when relevant:** 
- If building email-heavy feature, start with Amazon SES
- Cloudflare ($354/mo) is good mid-range option for better UX/support
- Avoid Postmark unless enterprise compliance/deliverability is critical

**Tags:** `#infrastructure` `#cost-optimization` `#email` `#saas-pricing`

---
