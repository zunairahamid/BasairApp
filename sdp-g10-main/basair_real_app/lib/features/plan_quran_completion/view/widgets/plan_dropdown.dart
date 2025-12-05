import 'package:flutter/material.dart';

class PlanDropdown<PlanType> extends StatelessWidget {
  final PlanType? value;
  final List<PlanType>? items;
  final Function(PlanType?) onChanged;
  final String hintText;
  final IconData icon;

  const PlanDropdown({
    super.key,
    this.value,
    this.items,
    required this.onChanged,
    required this.hintText,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      padding: EdgeInsets.symmetric(horizontal: 8),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButton<PlanType>(
        value: value,
        isExpanded: true,
        underline: SizedBox(),
        icon: Icon(Icons.arrow_drop_down, color: Colors.black),
        hint: Row(
          children: [
            Icon(icon, color: Colors.black),
            SizedBox(width: 8),
            Text(
              hintText,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        items: items != null
            ? items!
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item.toString()),
                    ))
                .toList()
            : <PlanType>[
                "Surah" as PlanType,
                "Juz" as PlanType,
              ].map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Row(
                    children: [
                      Icon(Icons.book_sharp, color: Colors.black),
                      SizedBox(width: 8),
                      Text(item.toString()),
                    ],
                  ),
                );
              }).toList(),
        onChanged: onChanged,
        dropdownColor: Colors.indigo.shade50,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        borderRadius: BorderRadius.circular(30),
        menuMaxHeight: 200,
      ),
    );
  }
}
