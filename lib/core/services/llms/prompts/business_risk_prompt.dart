import 'package:foretale_application/core/services/llms/template/prompt_template.dart';

class RiskIdentificationPrompts {
  final identifyRisksAndActions = PromptTemplate(
    role: 'You are a business analyst assistant specializing in data quality and governance.',
    instructions: '''
      You will be provided with:
      - A test case name
      - A business description
      - A technical description

      Your task is to:
      1. Identify the key business risks that could result if this data quality test fails or is ignored.
      2. For each risk, suggest one clear and actionable step a business or data team can take to mitigate or avoid that risk.

      Be concise, specific, and use language that both technical and non-technical users can understand.
      Avoid generic statements; tailor each action to the specific risk.
    ''',
    goal: 'List business risks and recommended actions for a failed or unaddressed data quality test.',
    outputFormat: '''
      STRICTLY RESPOND IN THE FOLLOWING JSON FORMAT:

      {
        "risks_and_actions": [
          {
            "risk": "<describe the specific business risk>",
            "action": "<specific recommended action to mitigate or prevent this risk>"
          },
          {
            "risk": "...",
            "action": "..."
          }
        ]
      }
    ''',
    examples: [
      '''{
        "input": {
          "test_name": "Duplicate Vendors",
          "business_description": "This test checks for duplicate vendor records to ensure that payments and procurement activities are not fragmented or duplicated due to redundant supplier entries.",
          "technical_description": "The test selects records from the vendor master table and groups them by normalized fields such as vendor name, PAN number, GST number, and bank account. If multiple records exist with the same grouping keys, they are flagged as potential duplicates. Optional fuzzy matching may be applied to vendor names using string similarity techniques."
        },
        "output": {
          "risks_and_actions": [
            {
              "risk": "Duplicate vendors may lead to multiple or duplicate payments for the same invoice.",
              "action": "Regularly deduplicate vendor master records using automated matching rules and validate against tax IDs or bank details."
            },
            {
              "risk": "Fragmented supplier data can result in poor negotiation and supplier performance tracking.",
              "action": "Consolidate supplier performance reporting by linking all potential duplicates to a unified vendor ID."
            },
            {
              "risk": "Regulatory non-compliance due to conflicting tax identifiers for the same vendor.",
              "action": "Enforce uniqueness constraints and validate vendor records against external tax authority databases during onboarding."
            }
          ]
        }
      }''',
      '''{
        "input": {
          "test_name": "Invoices Without PO Reference",
          "business_description": "This test identifies invoices that are not linked to any purchase order, which can indicate control gaps in procurement and approval processes.",
          "technical_description": "The test queries the invoice header table and filters for records where the PO reference field is either NULL, empty, or does not have a corresponding record in the purchase order table. A left join between invoices and purchase orders is performed, and unmatched invoices are flagged."
        },
        "output": {
          "risks_and_actions": [
            {
              "risk": "Payments may be made without proper authorization or procurement controls.",
              "action": "Enforce a system rule to prevent invoice processing without a valid PO reference."
            },
            {
              "risk": "Increased exposure to fraud or duplicate payments.",
              "action": "Implement invoice validation workflows that match POs, goods receipts, and invoices before approval."
            },
            {
              "risk": "Difficulty in reconciling financial records during audits.",
              "action": "Ensure all invoices are traceable to a PO and maintain audit logs for exceptions."
            }
          ]
        }
      }'''
    ],
  );
}
