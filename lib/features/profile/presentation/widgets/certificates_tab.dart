import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/custom_text.dart';
import '../../../dashboard/application/states/profile_list_state.dart';

class CertificatesTab extends StatelessWidget {
  final ProfileItem profile;

  const CertificatesTab({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final certificates = profile.documents
        .where((d) => d.type == 'EVENT' || d.type == 'CERTIFICATE')
        .toList();

    if (certificates.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(40.h),
        child: Center(
          child: CustomText(
            'No certificates uploaded',
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white54,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: certificates
            .map((doc) => _buildCertificateCard(context, doc))
            .toList(),
      ),
    );
  }

  Widget _buildCertificateCard(BuildContext context, DocumentItem doc) {
    final fileName = doc.normalizedUrl.split('/').last;
    final isImage =
        doc.normalizedUrl.toLowerCase().endsWith('.jpg') ||
        doc.normalizedUrl.toLowerCase().endsWith('.png') ||
        doc.normalizedUrl.toLowerCase().endsWith('.jpeg');

    return GestureDetector(
      onTap: () {
        // TODO: Open certificate in full screen or browser
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Open: ${doc.normalizedUrl}')));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Container(
              height: 140.h,
              width: double.infinity,
              margin: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: Colors.black26,
                image: isImage
                    ? DecorationImage(
                        image: NetworkImage(doc.normalizedUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: !isImage
                  ? Center(
                      child: Icon(
                        Icons.description,
                        size: 48.sp,
                        color: Colors.white54,
                      ),
                    )
                  : null,
            ),
            // Title Section
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: Row(
                children: [
                  Icon(
                    isImage ? Icons.image : Icons.description_outlined,
                    color: Colors.white70,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: CustomText(
                      fileName,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.open_in_new, color: Colors.white54, size: 18.sp),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
