import 'package:flutter/material.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/themes/scaffold_styles.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';

class ReportBusinessRisksTab extends StatelessWidget {
  const ReportBusinessRisksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ScaffoldStyles.layoutBodyPanelBoxDecoration(),
      margin: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business Risks Section
            _buildSectionCard(
              child: _buildBusinessRisks(),
              title: "Business Risks",
              icon: Icons.warning_amber,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessRisks() {
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Financial Risks
          _buildRiskItem(
            context,
            "Financial Risks",
            "Potential financial losses and exposure",
            [
              "• Duplicate payments risk: \$45,000 potential exposure",
              "• Overpayment risk: \$12,500 identified variance",
              "• Fraud risk: Medium probability based on patterns",
            ],
            Icons.attach_money,
            Colors.red,
          ),
          const SizedBox(height: 16),
          
          // Operational Risks
          _buildRiskItem(
            context,
            "Operational Risks",
            "Process inefficiencies and control weaknesses",
            [
              "• Manual override procedures: 23% of transactions",
              "• Incomplete documentation: 15% of POs missing details",
              "• Vendor master data: 8% inconsistent records",
            ],
            Icons.engineering,
            Colors.orange,
          ),
          const SizedBox(height: 16),
          
          // Compliance Risks
          _buildRiskItem(
            context,
            "Compliance Risks",
            "Regulatory and policy compliance concerns",
            [
              "• SOX compliance: Segregation of duties violations",
              "• Audit trail: Incomplete documentation for 12% of transactions",
              "• Policy adherence: 18% transactions outside approval limits",
            ],
            Icons.gavel,
            Colors.purple,
          ),
          const SizedBox(height: 16),
          
          // Reputational Risks
          _buildRiskItem(
            context,
            "Reputational Risks",
            "Potential damage to business relationships",
            [
              "• Vendor relationships: Payment delays affecting 45 vendors",
              "• Internal stakeholders: Process inefficiencies causing delays",
              "• External auditors: Control weaknesses requiring remediation",
            ],
            Icons.business,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildRiskItem(
    BuildContext context,
    String title,
    String description,
    List<String> points,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyles.titleText(context).copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyles.subtitleText(context).copyWith(
                        fontSize: 12,
                        color: TextColors.hintTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...points.map((point) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              point,
              style: TextStyles.gridText(context).copyWith(
                fontSize: 12,
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required Widget child,
    required String title,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: BorderColors.tertiaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(
                  color: BorderColors.tertiaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Builder(
                    builder: (context) => Text(
                      title,
                      style: TextStyles.titleText(context).copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Section Content
          Container(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ],
      ),
    );
  }
} 