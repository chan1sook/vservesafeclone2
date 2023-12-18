import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:vservesafe/src/models/site_data.dart';

class SiteSelectedComponent extends StatelessWidget {
  const SiteSelectedComponent({
    super.key,
    required this.sites,
    this.selectedSite,
    this.onChangeSite,
  });

  final List<VserveSiteData> sites;
  final VserveSiteData? selectedSite;
  final Function(VserveSiteData?)? onChangeSite;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
        border: OutlineInputBorder(),
      ),
      value: selectedSite?.id,
      onChanged: (value) {
        final targetSite = sites.firstWhereOrNull((ele) => ele.id == value);
        onChangeSite?.call(targetSite);
      },
      items: sites.map((site) {
        return DropdownMenuItem<String>(
          value: site.id,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundImage: NetworkImage(site.serverLogoUrl),
              ),
              const SizedBox(width: 7),
              Text(
                site.name,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
