import 'package:flutter/material.dart';
import 'package:foretale_application/ui/screens/report/report_overview_tab.dart';
import 'package:foretale_application/ui/screens/report/report_test_results_tab.dart';
import 'package:foretale_application/ui/screens/report/report_detailed_findings_tab.dart';
import 'package:foretale_application/ui/screens/report/report_business_risks_tab.dart';
import 'package:foretale_application/ui/screens/report/report_recommendations_tab.dart';
import 'package:foretale_application/ui/screens/report/report_additional_analysis_tab.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';

class RiskReportPage extends StatefulWidget {
  const RiskReportPage({super.key});

  @override
  State<RiskReportPage> createState() => _RiskReportPageState();
}

class _RiskReportPageState extends State<RiskReportPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BodyColors.bodyBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppBarColors.appBarBackgroundColor.withOpacity(0.05),
        title: Text(
          "Risk & Assurance Report",
          style: TextStyles.appBarTitleStyle(context),
        ),
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primaryColor,
          indicatorWeight: 4,
          labelStyle: TextStyles.tabSelectedLabelText(context),
          unselectedLabelStyle: TextStyles.tabUnselectedLabelText(context),
          tabs: [
            buildTab(
              icon: Icons.assessment,
              label: 'Overview',
            ),
            buildTab(
              icon: Icons.table_chart,
              label: 'Test Summary',
            ),
            buildTab(
              icon: Icons.find_in_page,
              label: 'Detailed Findings',
            ),
            buildTab(
              icon: Icons.warning_amber,
              label: 'Business Risks',
            ),
            buildTab(
              icon: Icons.lightbulb_outline,
              label: 'Recommendations',
            ),
            buildTab(
              icon: Icons.analytics,
              label: 'Additional Analysis',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          // Overview Tab
          ReportOverviewTab(),
          // Test Results Summary Tab
          ReportTestResultsTab(),
          // Detailed Findings Tab
          ReportDetailedFindingsTab(),
          // Business Risks Tab
          ReportBusinessRisksTab(),
          // Recommendations Tab
          ReportRecommendationsTab(),
          // Additional Analysis Tab
          ReportAdditionalAnalysisTab(),
        ],
      ),
    );
  }

  Widget buildTab({
    required IconData icon,
    required String label,
    Color color = AppColors.primaryColor,
  }) {
    return Tab(
      child: FittedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyles.subjectText(context),
            ),
          ],
        ),
      ),
    );
  }
}
