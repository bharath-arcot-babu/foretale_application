const Map<String, List<String>> feedbackDropdownOptions = {
  'feedback_status': ['New', 'In Review', 'Accepted', 'Rejected', 'Corrected', 'Not an Issue'],
  'feedback_category': ['Data Error', 'Duplicate', 'System Issue', 'Process Issue',' Out of Scope', 'Manual Override', 'Other'],
  'severity_rating': ['Low', 'Medium', 'High', 'Critical'],
};

const List<String> systemNames = [
  'SAP',
  'Oracle',
  'Salesforce',
  'Microsoft Dynamics',
  'NetSuite',
  'QuickBooks',
  'Xero',
  'Sage',
  'Infor',
  'Epicor',
  'Other'
];

const List<String> projectScopeOptions = [
  'Last 3 months',
  'Last 6 months',
  'Last 12 months',
  'Last 2 years',
  'Last 3 years',
  'Last 5 years',
  'All available data',
  'Custom period'
];