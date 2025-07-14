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
      4. A **Financial Impact**: What is the appropriate way to measure the financial impact of the test considering the data quering possiblities.

      Be specific, concise, and relevant to the given domain. Do not make up data or use placeholders.
    ''',
    goal: 'Generate a readable test name, business description, and technical description for a data quality test case.',
    outputFormat: '''
      STRICTLY RESPOND IN THE FOLLOWING JSON FORMAT:

      {
        "rewritten_test_name": "<cleaned, readable test name for UI or documentation>",
        "business_description": "<brief, clear explanation of the purpose of the test in business terms>",
        "technical_description": "<clear and accurate explanation of the test logic or rule applied>",
        "financial_impact": "<appropriate way to measure the financial impact of the test considering the data quering possiblities>"
      }
    ''',
    examples: [
      '''{
        "input": {
          "project_type": "P2P",
          "topic": "Supplier Management",
          "test_name": "Duplicate Vendors"
        },
        "output": {
          "rewritten_test_name": "Duplicate Vendors",
          "business_description": "This test checks for duplicate vendor records to ensure that payments and procurement activities are not fragmented or duplicated due to redundant supplier entries.",
          "technical_description": "The test selects records from the vendor master table and groups them by normalized fields such as vendor name, and TAX ID. If multiple records exist with the same grouping keys, they are flagged as potential duplicates. Optional fuzzy matching may be applied to vendor names using string similarity techniques.",
          "financial_impact_formula": "N/A"
        }
      }''',
      '''{
        "input": {
          "project_type": "P2P",
          "topic": "Invoice Processing",
          "test_name": "Invoices Without PO Reference"
        },
        "output": {
          "rewritten_test_name": "Invoices Missing PO Reference",
          "business_description": "This test identifies invoices that are not linked to any purchase order, which can indicate control gaps in procurement and approval processes.",
          "technical_description": "The test queries the invoice header table and filters for records where the PO reference field is either NULL, empty, or does not have a corresponding record in the purchase order table. A left join between invoices and purchase orders is performed, and unmatched invoices are flagged.",
          "financial_impact_formula": "SUM of invoice amount for invoices that are not linked to any purchase order."
        }
      }'''
    ],
  );
}
