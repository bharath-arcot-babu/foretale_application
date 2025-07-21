import 'package:foretale_application/core/services/llms/template/prompt_template.dart';

class TestCasePrompts {
  final generateDescriptions = PromptTemplate(
    role: 'You are a data quality assistant that creates documentation for test cases.',
    instructions: '''
You will be given:
- A project type (e.g., P2P, O2C, H2R)
- A topic or domain area (e.g., Supplier Management, Invoice Processing)
- A test case name (e.g., Duplicate Vendors, Invoices Without PO)

Based on this information, your task is to write:

1. A **rewritten test name**: A cleaned, properly capitalized version of the test name suitable for display.
2. A **business description**: A brief explanation of what the test checks and why it matters, in business-friendly language.
3. A **technical description**: A clear explanation of the underlying logic, rules, or assumptions used to detect the issue — suitable for a data engineer or developer.
4. A **financial impact**: Provide the calculation logic to quantify the financial impact using available data — for example:
   - Flagged transaction count vs total
   - Cost per document
   - Average value per transaction
   Use the format: `(flag_count / total_count) × cost_per_unit`, or `SUM(column) WHERE <condition>`
5. A **proxy metrics**: Suggest indirect metrics that can be used if exact financial data is unavailable (e.g., number of duplicates, processing time, system overhead).
6. A **qualitative impact framing**: Describe the business risk or inefficiency caused by the issue when quantification is not possible.
7. An **impact estimation scenario**: Offer a simple example scenario with low/medium/high ranges to estimate potential losses.
8. **benchmarks or industry references**: Mention relevant industry average costs or error rates that can be referenced if internal data is not available.

Be specific, concise, and relevant to the given domain. Do not make up data or use placeholders.
''',
    goal: 'Generate a test case documentation bundle that explains business, technical, and financial relevance of a data quality test.',
    outputFormat: '''
STRICTLY RESPOND IN THE FOLLOWING JSON FORMAT:

{
  "rewritten_test_name": "<cleaned, readable test name for UI or documentation>",
  "business_description": "<brief, clear explanation of the purpose of the test in business terms>",
  "technical_description": "<clear and accurate explanation of the test logic or rule applied>",
  "financial_impact": "<exact method to calculate financial impact using queryable data fields or ratios>",
  "proxy_metrics": "<list of indirect metrics if financial data is unavailable>",
  "qualitative_impact_framing": "<statement describing the business risk or inefficiency if not quantifiable>",
  "impact_estimation_scenario": "<a rough calculation scenario to show low/medium/high impact ranges>",
  "benchmarks_or_industry_references": "<external cost benchmarks or standard rates for industry comparison>"
}
''',
    examples: [
      '''{
  "input": {
    "project_type": "P2P",
    "topic": "Purchase Order Processing",
    "test_name": "Duplicate Purchase Orders"
  },
  "output": {
    "rewritten_test_name": "Duplicate Purchase Orders",
    "business_description": "This test identifies purchase orders that appear to be duplicates, which can lead to double ordering, excess inventory, and increased processing cost.",
    "technical_description": "The test checks for POs with matching vendor, amount, date, and material within a short time window. Records are flagged if multiple POs exist with similar details.",
    "financial_impact": "(COUNT(flagged_POs) / COUNT(total_POs_in_scope)) × average_PO_processing_cost",
    "proxy_metrics": "Number of flagged POs, processing time per PO, overhead from rework or cancellations",
    "qualitative_impact_framing": "Duplicate POs create procurement confusion and may result in unnecessary inventory or overpayment.",
    "impact_estimation_scenario": "If 5% of 10,000 POs are duplicates and each costs \$50 to process, the waste could be \$25,000/year.",
    "benchmarks_or_industry_references": "APQC reports \$60 average processing cost per PO; industry error rates for duplicate POs range from 2%–5%."
  }
}'''
    ],
  );
}
