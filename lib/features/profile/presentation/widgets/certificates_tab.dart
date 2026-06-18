import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/services/session_prefs.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../onboarding/domain/document_models.dart';
import '../../../onboarding/domain/document_service.dart';

class CertificatesTab extends StatefulWidget {
  final String portfolioId;

  const CertificatesTab({super.key, required this.portfolioId});

  @override
  State<CertificatesTab> createState() => CertificatesTabState();
}

class CertificatesTabState extends State<CertificatesTab> {
  List<DocumentInfo> _certificates = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCertificates();
  }

  Future<void> _fetchCertificates() async {
    if (widget.portfolioId.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await SessionPrefs.instance.getAccessToken();
      final service = DocumentService();
      final response = await service.getDocumentsForProfile(
        profileId: widget.portfolioId,
        accessToken: token.isNotEmpty ? token : '',
      );

      final status = response['status'] as int?;
      final success = response['success'] as bool?;
      debugPrint(
        'CertificatesTab: portfolioId=${widget.portfolioId} '
        'status=$status success=$success '
        'keys=${response.keys.toList()}',
      );
      if (status != 200 && success == false) {
        setState(() {
          _isLoading = false;
          _error = response['message'] as String? ?? 'Failed to load';
        });
        return;
      }

      final data = response['data'];
      debugPrint(
        'CertificatesTab: data type=${data.runtimeType} '
        '${data is List ? 'len=${data.length}' : ''}',
      );
      final docs = <DocumentInfo>[];
      if (data is List) {
        for (final item in data) {
          if (item is Map<String, dynamic>) {
            try {
              final doc = DocumentInfo.fromJson(item);
              final docType = doc.type.toUpperCase();
              if (docType == 'EVENT' || docType == 'CERTIFICATE') {
                docs.add(doc);
              }
            } catch (_) {}
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _certificates = docs;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('CertificatesTab: fetch error: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  /// Call this after uploading a new certificate to refresh the list.
  void refresh() => _fetchCertificates();

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Padding(
        padding: EdgeInsets.all(40.h),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: EdgeInsets.all(40.h),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                'Failed to load certificates',
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white54,
              ),
              SizedBox(height: 12.h),
              TextButton(
                onPressed: _fetchCertificates,
                child: CustomText(
                  'Retry',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_certificates.isEmpty) {
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
        children: _certificates
            .map((doc) => _buildCertificateCard(context, doc))
            .toList(),
      ),
    );
  }

  Widget _buildCertificateCard(BuildContext context, DocumentInfo doc) {
    final url = doc.url.startsWith('http://')
        ? doc.url.replaceFirst('http://', 'https://')
        : doc.url;
    final fileName = url.split('/').last;
    final isImage = url.toLowerCase().endsWith('.jpg') ||
        url.toLowerCase().endsWith('.png') ||
        url.toLowerCase().endsWith('.jpeg');

    return GestureDetector(
      onTap: () async {
        // Don't gate on canLaunchUrl — on Android 11+ it returns false
        // negatives for web URLs unless the manifest declares <queries>
        // for the browser intent, which silently made tapping a no-op.
        // Launching an intent itself doesn't need package visibility, so
        // just launch and handle any failure.
        final messenger = ScaffoldMessenger.of(context);
        final uri = Uri.parse(url);
        try {
          final launched =
              await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (!launched) {
            await launchUrl(uri, mode: LaunchMode.platformDefault);
          }
        } catch (_) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Could not open the certificate.'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
            Container(
              height: 140.h,
              width: double.infinity,
              margin: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: Colors.black26,
                image: isImage
                    ? DecorationImage(
                        image: NetworkImage(url),
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
