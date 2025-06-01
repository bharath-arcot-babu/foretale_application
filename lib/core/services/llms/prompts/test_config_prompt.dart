import 'package:foretale_application/core/services/llms/template/prompt_template.dart';

class TestConfigPrompt {
  final PromptTemplate clarifyPrompt = PromptTemplate(
    role: 'You are a SQL Server and a test case expert.',
    instructions: '''
                  You are given a test case with a name and description. 
                  Your job is to thoroughly understand the test case by its name and description and follow the steps below.

                  STEP 1 — Understand the test case.
                  - Read and interpret the **test case name and description**.

                  STEP 2 — Read the past user responses in the order they are provided below.
                  - Read the past user responses to eliminate the question that is already answered. Don't ask the same question again.

                  STEP 3 — Check if there are enough clarifications.
                  - If you think, there are enough clarifications, you can skip the next steps.
                  - BEFORE generating questions, first ask yourself:
                    - "Do I already have enough information to write a clear SQL query? If yes, stop."
                    - If NO, only ask business questions, that would *significantly* change the query logic. 

                  STEP 4 — Prepare the most essential clarifying question. ONLY ONE QUESTION AT A TIME.
                  - The question should be able to clarify business intent, such as definitions, rules, and filters.
                  - Only ask a clarifying question if:
                    - The answer is essential to complete the SQL query.
                    - The answer is essential to avoid ambiguity.
                    - You are unsure about a specific business rule.
                  - Avoid questions that are optional, nice-to-have, or speculative.  

                  List of DO NOT's:
                  - DO NOT GENERATE SQL QUERY.
                  - DO NOT EXPLICITLY ASK TO FILTER DATA FOR EXAMPLE: by supplier, by customer, by product, by category,etc.
                  - DO NOT ASK ABOUT:
                    - Table names
                    - Column names
                    - Data types
                  ''',
    goal:
        'Elicit missing details or ambiguities in the user request that are necessary to write a correct SQL query for the test case.',
    outputFormat: '''
                  STRICTLY FOLLOW THE BELOW OUTPUT FORMAT. OUTPUT FORMAT SHOULD NEVER CHANGE. ONLY ONE QUESTION AT A TIME.
                  {
                    "question": "<Question>",
                    "reason": "<Reason for the question and how it helps to generate a correct SQL query for the test case. Keep it short and concise.>",
                  }
                  If everything is clear, respond with:
                  {
                    "question": "No more questions",
                    "reason": "No more questions",
                  }
                  ''',
  );

  final PromptTemplate tableIdentificationPrompt = PromptTemplate(
    role: 'You are a SQL Server and a test case expert.',
    instructions: 
    '''
      You are given a test case with a name and description.
      Your job is to thoroughly understand the test case by its name and description and identify the tables that are necessary to write a correct SQL SERVER query for the test case.
    ''',
    goal: 'Identify the tables that are necessary to write a correct SQL SERVER query for the test case.',
    outputFormat: '''
      {
        "tables": [List of tables that are necessary to write a correct SQL SERVER query for the test case.]",
      }
      If everything is clear, respond with:
      {
        "tables": "No more tables",
      }
    ''',
    examples: [
            '''
            Test Case: Identify invalid Purchase Orders by amount.
            {
              "tables": ["PurchaseOrders"]
            }
            ''',
              '''
            Test Case: Identify duplicate Purchase Orders and Invoices by amount.
            {
              "tables": ["PurchaseOrders", "Invoices"]
            }
          '''
        ],
  );
}
