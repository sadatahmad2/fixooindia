import 'package:flutter/material.dart';
import 'package:fixoo/screens/location_picker_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fixoo/providers/booking_provider.dart';
import 'package:fixoo/providers/notification_provider.dart';
import 'package:fixoo/screens/bookings_screen.dart';
import 'package:fixoo/screens/tracking_screen.dart';
import 'package:fixoo/services/supabase_service.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:geolocator/geolocator.dart';

class BookingScreen extends StatefulWidget {
  final String serviceName;
  final IconData icon;

  const BookingScreen({
    super.key,
    required this.serviceName,
    required this.icon,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String? selectedCompany;
  final List<String> selectedProblems = [];
  String selectedDay = 'Today';
  DateTime? customDate;
  String _currentAddress = "Lucknow, Uttar Pradesh";
  final TextEditingController _otherProblemController = TextEditingController();
  final TextEditingController _customCompanyController = TextEditingController();
  bool isOtherProblemSelected = false;
  bool isOtherCompanySelected = false;

  final Map<String, List<String>> serviceCompanies = {
    'Fan Repair': ['Orient', 'Crompton', 'Havells', 'Bajaj', 'Usha', 'Luminous', 'Khaitan', 'Polar', 'Orpat', 'Anchor', 'V-Guard', 'Surya', 'Panasonic', 'Other'],
    'AC Repair': ['Samsung', 'LG', 'Voltas', 'Daikin', 'Blue Star', 'Lloyd', 'Hitachi', 'Carrier', 'Panasonic', 'Godrej', 'Whirlpool', 'Haier', 'Mitsubishi', 'O General', 'Other'],
    'Water Motor Repair': ['Kirloskar', 'Crompton', 'Havells', 'Texmo', 'V-Guard', 'CRI', 'Suguna', 'Lubi', 'Varuna', 'Oswal', 'Other'],
    'Water Purifier Repair': ['Kent', 'Aquaguard', 'Pureit', 'Livpure', 'Blue Star', 'HUL', 'AO Smith', 'Nasaka', 'Tata Swach', 'Other'],
    'TV Repair': ['Sony', 'Samsung', 'LG', 'Mi', 'OnePlus', 'Realme', 'TCL', 'Vu', 'Panasonic', 'BPL', 'Sansui', 'Micromax', 'Haier', 'Other'],
    'Fridge Repair': ['Samsung', 'LG', 'Whirlpool', 'Haier', 'Godrej', 'Panasonic', 'Bosch', 'Lloyd', 'Kelvinator', 'Other'],
    'Washing Machine Repair': ['Samsung', 'LG', 'Whirlpool', 'Bosch', 'IFB', 'Haier', 'Godrej', 'Panasonic', 'Lloyd', 'Other'],
    'Laptop Repair': ['Apple', 'Dell', 'HP', 'Lenovo', 'Asus', 'Acer', 'MSI', 'Microsoft', 'Samsung', 'Razer', 'Other'],
    'Mobile Repair': ['Apple', 'Samsung', 'Mi', 'OnePlus', 'Vivo', 'Oppo', 'Realme', 'Google', 'Motorola', 'Nokia', 'Poco', 'Other'],
    'Cooler Repair': ['Symphony', 'Bajaj', 'Kenstar', 'Orient', 'Hindware', 'Maharaja Whiteline', 'Havells', 'Voltas', 'Other'],
    'Light Repair': ['Philips', 'Syska', 'Havells', 'Halonix', 'Bajaj', 'Surya', 'Orient', 'Wipro', 'Other'],
    // Appliance Fitting
    'AC Installation': ['Samsung', 'LG', 'Voltas', 'Daikin', 'Blue Star', 'Lloyd', 'Hitachi', 'Carrier', 'Godrej', 'Whirlpool', 'O General', 'Other'],
    'Fan Installation': ['Orient', 'Crompton', 'Havells', 'Bajaj', 'Usha', 'Luminous', 'Khaitan', 'V-Guard', 'Other'],
    'TV Setup': ['Sony', 'Samsung', 'LG', 'Mi', 'OnePlus', 'Realme', 'TCL', 'Vu', 'Panasonic', 'Other'],
    'Fridge Setup': ['Samsung', 'LG', 'Whirlpool', 'Haier', 'Godrej', 'Panasonic', 'Bosch', 'Other'],
    'Washing Machine Install': ['Samsung', 'LG', 'Whirlpool', 'Bosch', 'IFB', 'Haier', 'Godrej', 'Other'],
    // Wiring
    'Full Home Wiring': ['FixooIndia', 'Havells', 'Polycab', 'Finolex', 'V-Guard', 'RR Kabel', 'KEI', 'Anchor', 'Other'],
    'Extension Wiring': ['FixooIndia', 'Havells', 'Polycab', 'Finolex', 'Anchor', 'KEI', 'Other'],
    'Switch Board Fix': ['FixooIndia', 'Havells', 'Legrand', 'Anchor', 'GM Modular', 'Schneider', 'Other'],
    'MCB/Fuse Change': ['FixooIndia', 'Havells', 'Legrand', 'Anchor', 'Schneider', 'L&T', 'Other'],
    'Internal Wire Fault': ['FixooIndia', 'Havells', 'Polycab', 'Finolex', 'V-Guard', 'Other'],
    // Plumbing
    'Full Plumbing': ['FixooIndia', 'Ashirvad', 'Supreme', 'Prince', 'Finolex', 'Astral', 'Other'],
    'Pipe Leak Fix': ['FixooIndia', 'Ashirvad', 'Supreme', 'Finolex', 'Astral', 'Other'],
    'Tap Repair': ['FixooIndia', 'Jaquar', 'Hindware', 'Kohler', 'Grohe', 'Parryware', 'Cera', 'Other'],
    'New Pipe Fitting': ['FixooIndia', 'Ashirvad', 'Supreme', 'Astral', 'Other'],
    'Drainage Clearing': ['FixooIndia', 'Generic', 'Other'],
    // Cleaning
    'Room Cleaning': ['N/A'],
    'Bathroom Cleaning': ['N/A'],
    'Kitchen Cleaning': ['N/A'],
    'Full Home Cleaning': ['N/A'],
    // Carpentry
    'Door Repair & Fitting': ['FixooIndia', 'Generic', 'Other'],
    'Lock & Handle Installation': ['Godrej', 'Harrison', 'Link', 'FixooIndia', 'Other'],
    'Furniture Assembly/Repair': ['IKEA', 'FixooIndia', 'Generic', 'Other'],
    'Bed/Sofa Repair': ['FixooIndia', 'Generic', 'Other'],
    'Wardrobe/Cabinet Repair': ['FixooIndia', 'Generic', 'Other'],
    'Kitchen Drawer Fix': ['Hettich', 'Ebco', 'FixooIndia', 'Other'],
    'Wood Polishing & Finish': ['Asian Paints', 'Sirca', 'ICA', 'FixooIndia', 'Other'],
    'Custom Furniture Making': ['FixooIndia', 'Other'],
    // Interior
    'Modular Kitchen Design': ['Hettich', 'Hafele', 'FixooIndia', 'Other'],
    'False Ceiling (POP/PVC)': ['Gyproc', 'FixooIndia', 'Other'],
    'Wallpaper Installation': ['Marshalls', 'FixooIndia', 'Other'],
    'PVC Wall Panel Fitting': ['FixooIndia', 'Generic', 'Other'],
    'TV Unit & Wardrobe Design': ['FixooIndia', 'Other'],
    'Wooden/Laminate Flooring': ['FixooIndia', 'Generic', 'Other'],
    'Lighting & Decoration': ['Philips', 'Havells', 'FixooIndia', 'Other'],
    'Full Home Interior': ['FixooIndia', 'Other'],
    // Painting
    'Full House Painting (Int)': ['Asian Paints', 'Berger', 'Nerolac', 'Dulux', 'FixooIndia', 'Other'],
    'Exterior Wall Painting': ['Asian Paints', 'Berger', 'Nerolac', 'Dulux', 'FixooIndia', 'Other'],
    'Single Room Painting': ['Asian Paints', 'Berger', 'Nerolac', 'Dulux', 'FixooIndia', 'Other'],
    'Texture & Stencil Design': ['Asian Paints', 'Berger', 'FixooIndia', 'Other'],
    'Waterproofing Treatment': ['Dr. Fixit', 'Fosroc', 'FixooIndia', 'Other'],
    'Putty & Primer Work': ['JK Wall Putty', 'Birla White', 'FixooIndia', 'Other'],
    'Door & Window Polishing': ['Asian Paints', 'FixooIndia', 'Other'],
    'Metal/Gate Painting': ['Asian Paints', 'Berger', 'FixooIndia', 'Other'],
  };

  final Map<String, Map<String, String>> servicePrices = {
    'Fan Repair': {
      'Fan Not Working': '₹199 – ₹349',
      'Fan Running Slow': '₹149 – ₹249',
      'Fan Making Noise': '₹149 – ₹299',
      'Fan Overheating': '₹199 – ₹399',
      'Fan Stopping Frequently': '₹149 – ₹299',
      'Regulator Issue': '₹149 – ₹299',
      'Switch / Wiring Issue': '₹149 – ₹299',
      'Other': '₹99 (inspection)',
    },
    'AC Repair': {
      'AC Not Cooling': '₹299 – ₹799',
      'AC Not Turning On': '₹299 – ₹699',
      'Water Leakage': '₹249 – ₹499',
      'Gas Filling Issue': '₹1500 – ₹2500',
      'Cooling Too Low': '₹299 – ₹699',
      'AC Making Noise': '₹249 – ₹499',
      'Remote Not Working': '₹149 – ₹299',
      'Other': '₹149 (inspection)',
    },
    'Water Motor Repair': {
      'Motor Not Starting': '₹199 – ₹399',
      'Low Water Pressure': '₹149 – ₹299',
      'Motor Making Noise': '₹149 – ₹299',
      'Auto Cut Not Working': '₹199 – ₹399',
      'Overheating': '₹199 – ₹399',
      'Water Not Coming': '₹149 – ₹299',
      'Other': '₹99 (inspection)',
    },
    'Water Purifier Repair': {
      'Water Not Coming': '₹199 – ₹399',
      'Bad Taste / Smell': '₹299 – ₹799',
      'Filter Change Needed': '₹500 – ₹1500',
      'Leakage Issue': '₹199 – ₹399',
      'Low Water Flow': '₹199 – ₹399',
      'Machine Not Working': '₹299 – ₹699',
      'Other': '₹149 (inspection)',
    },
    'TV Repair': {
      'TV Not Turning On': '₹299 – ₹799',
      'No Display / Black Screen': '₹499 – ₹1500',
      'Sound Issue': '₹249 – ₹499',
      'Remote Not Working': '₹149 – ₹299',
      'Screen Damage': '₹2000+',
      'HDMI / Port Issue': '₹249 – ₹499',
      'Other': '₹149 (inspection)',
    },
    'Fridge Repair': {
      'Not Cooling': '₹299 – ₹799',
      'Over Cooling (ice jam)': '₹249 – ₹499',
      'Water Leakage': '₹199 – ₹399',
      'Compressor Issue': '₹1500 – ₹4000',
      'Noise Problem': '₹249 – ₹499',
      'Door Not Closing': '₹199 – ₹399',
      'Other': '₹149 (inspection)',
    },
    'Washing Machine Repair': {
      'Not Starting': '₹299 – ₹699',
      'Water Not Filling': '₹199 – ₹399',
      'Not Spinning': '₹299 – ₹699',
      'Vibration': '₹249 – ₹499',
      'Drain Issue': '₹199 – ₹399',
      'Noise': '₹249 – ₹499',
      'Other': '₹149 (inspection)',
    },
    'Laptop Repair': {
      'Not Turning On': '₹499 – ₹1500',
      'Battery Issue': '₹800 – ₹2500',
      'Heating': '₹299 – ₹699',
      'Slow': '₹299 – ₹799',
      'Screen Issue': '₹2000+',
      'Keyboard': '₹499 – ₹1500',
      'Charging Issue': '₹499 – ₹1200',
      'Other': '₹199 (inspection)',
    },
    'Mobile Repair': {
      'Screen Broken': '₹1000 – ₹5000',
      'Battery Issue': '₹500 – ₹1500',
      'Not Charging': '₹299 – ₹799',
      'Speaker Issue': '₹299 – ₹799',
      'Touch Issue': '₹1000 – ₹3000',
      'Network Issue': '₹299 – ₹799',
      'Software Issue': '₹299 – ₹699',
      'Other': '₹149 (inspection)',
    },
    'Cooler Repair': {
      'Cooler Not Working': '₹149 – ₹299',
      'Air Not Cooling': '₹149 – ₹299',
      'Fan Issue': '₹149 – ₹299',
      'Pump Issue': '₹199 – ₹399',
      'Water Leakage': '₹149 – ₹299',
      'Noise': '₹149 – ₹299',
      'Pad Change': '₹200 – ₹500',
      'Other': '₹99 (inspection)',
    },
    'Light Repair': {
      'Bulb/Tube Not Working': '₹99 – ₹199',
      'Flickering Issue': '₹149 – ₹249',
      'Holder Damage': '₹99 – ₹199',
      'Switch Problem': '₹99 – ₹199',
      'Hanging Light Install': '₹199 – ₹499',
      'Decorative Lights Setup': '₹299 – ₹799',
      'Other': '₹99 (inspection)',
    },
    // Appliance Fitting
    'AC Installation': {
      'Split AC Installation': '₹999 – ₹1999',
      'Window AC Installation': '₹699 – ₹1499',
      'AC Uninstallation': '₹499 – ₹999',
      'AC Shifting': '₹1499 – ₹2999',
      'Copper Piping': '₹400/ft',
      'AC Stand Setup': '₹299 – ₹599',
      'Other': '₹199 (inspection)',
    },
    'Fan Installation': {
      'Ceiling Fan Install': '₹199 – ₹399',
      'Exhaust Fan Install': '₹199 – ₹349',
      'Wall Fan Install': '₹149 – ₹299',
      'Decorative Fan Install': '₹299 – ₹599',
      'Fan Uninstallation': '₹99 – ₹199',
      'Other': '₹99 (inspection)',
    },
    'TV Setup': {
      'Wall Mount Install': '₹399 – ₹799',
      'TV Unboxing & Setup': '₹299 – ₹499',
      'Set-Top Box Setup': '₹149 – ₹299',
      'Home Theater Setup': '₹499 – ₹999',
      'TV Shifting': '₹399 – ₹799',
      'Other': '₹149 (inspection)',
    },
    'Fridge Setup': {
      'Single Door Setup': '₹299 – ₹499',
      'Double Door Setup': '₹399 – ₹699',
      'Side-by-Side Setup': '₹499 – ₹999',
      'Fridge Shifting': '₹499 – ₹999',
      'Stabilizer Install': '₹199 – ₹399',
      'Other': '₹149 (inspection)',
    },
    'Washing Machine Install': {
      'Front Load Install': '₹399 – ₹699',
      'Top Load Install': '₹299 – ₹499',
      'Semi-Auto Install': '₹199 – ₹399',
      'Drainage Setup': '₹199 – ₹399',
      'Inlet Pipe Setup': '₹149 – ₹299',
      'Other': '₹149 (inspection)',
    },
    // Wiring
    'Full Home Wiring': {
      '1 BHK Wiring': '₹5000 – ₹10000',
      '2 BHK Wiring': '₹8000 – ₹15000',
      '3 BHK Wiring': '₹12000 – ₹25000',
      'Rewiring (Old House)': '₹8000 – ₹20000',
      'MCB/DB Box Install': '₹999 – ₹2999',
      'Earthing Work': '₹1500 – ₹3000',
      'Other': '₹199 (inspection)',
    },
    'Extension Wiring': {
      'New Point Addition': '₹199 – ₹499',
      'Extension Board Wiring': '₹149 – ₹299',
      'Socket Addition': '₹149 – ₹299',
      'Concealed Wiring (per point)': '₹399 – ₹799',
      'External Wiring (per point)': '₹199 – ₹399',
      'Other': '₹149 (inspection)',
    },
    'Switch Board Fix': {
      'Single Switch Replace': '₹99 – ₹199',
      'Full Board Replace': '₹299 – ₹699',
      'Modular Switch Upgrade': '₹499 – ₹1499',
      'Dimmer Install': '₹199 – ₹399',
      'Short Circuit Fix': '₹199 – ₹499',
      'Other': '₹99 (inspection)',
    },
    'MCB/Fuse Change': {
      'MCB Replacement': '₹249 – ₹499',
      'Main Fuse Fix': '₹199 – ₹399',
      'DB Box Wiring': '₹499 – ₹999',
      'Short Circuit in DB': '₹299 – ₹699',
      'Other': '₹99 (inspection)',
    },
    'Internal Wire Fault': {
      'Wall Concealed Fault': '₹599 – ₹1499',
      'Burning Smell Check': '₹299 – ₹699',
      'Phase Missing Fix': '₹399 – ₹799',
      'Neutral Issue Fix': '₹399 – ₹799',
      'Other': '₹199 (inspection)',
    },
    // Plumbing
    'Full Plumbing': {
      'Bathroom Plumbing': '₹2000 – ₹5000',
      'Kitchen Plumbing': '₹1500 – ₹4000',
      'Full House Plumbing': '₹8000 – ₹20000',
      'Water Tank Install': '₹999 – ₹2999',
      'Pipeline Repair': '₹499 – ₹1499',
      'Other': '₹199 (inspection)',
    },
    'Pipe Leak Fix': {
      'Minor Leak Fix': '₹149 – ₹299',
      'Joint Leak Repair': '₹199 – ₹399',
      'Pipe Replacement': '₹299 – ₹799',
      'Underground Leak Fix': '₹499 – ₹1499',
      'Valve Replacement': '₹199 – ₹399',
      'Other': '₹99 (inspection)',
    },
    'Tap Repair': {
      'Tap Leak Fix': '₹99 – ₹199',
      'Tap Replacement': '₹199 – ₹499',
      'Mixer Tap Install': '₹299 – ₹699',
      'Sensor Tap Install': '₹499 – ₹999',
      'Tap Washer Replace': '₹49 – ₹99',
      'Other': '₹99 (inspection)',
    },
    'New Pipe Fitting': {
      'Inlet Pipe Install': '₹199 – ₹399',
      'Outlet Pipe Install': '₹249 – ₹499',
      'Concealed Piping': '₹499 – ₹999',
      'External Piping': '₹299 – ₹599',
      'Other': '₹149 (inspection)',
    },
    'Drainage Clearing': {
      'Sinks/Toilets Blockage': '₹299 – ₹599',
      'Main Line Clearing': '₹499 – ₹1499',
      'Drain Trap Clean': '₹199 – ₹399',
      'Sewer Line Repair': '₹999 – ₹2999',
      'Other': '₹199 (visit)',
    },
    // Cleaning
    'Room Cleaning': {
      '1 Room Deep Clean': '₹499 – ₹799',
      '2 Room Deep Clean': '₹799 – ₹1299',
      'Carpet Cleaning': '₹399 – ₹699',
      'Sofa Cleaning': '₹499 – ₹999',
      'Window Cleaning': '₹199 – ₹399',
      'Other': '₹299 (visit)',
    },
    'Bathroom Cleaning': {
      'Single Bathroom': '₹399 – ₹599',
      '2 Bathrooms': '₹599 – ₹999',
      'Deep Scrub + Disinfection': '₹499 – ₹799',
      'Tile Stain Removal': '₹299 – ₹499',
      'Drain Cleaning': '₹199 – ₹399',
      'Other': '₹199 (visit)',
    },
    'Kitchen Cleaning': {
      'Full Kitchen Clean': '₹599 – ₹999',
      'Chimney Cleaning': '₹399 – ₹699',
      'Gas Stove Clean': '₹199 – ₹399',
      'Sink & Drain Clean': '₹149 – ₹299',
      'Cabinet Cleaning': '₹299 – ₹499',
      'Other': '₹199 (visit)',
    },
    'Full Home Cleaning': {
      '1 BHK Deep Clean': '₹1999 – ₹2999',
      '2 BHK Deep Clean': '₹2999 – ₹4499',
      '3 BHK Deep Clean': '₹4499 – ₹6999',
      'Move-in/Move-out Clean': '₹2999 – ₹5999',
      'Post Construction Clean': '₹3999 – ₹7999',
      'Other': '₹499 (visit)',
    },
    // Carpentry Detail
    'Door Repair & Fitting': {
      'Door Swelling / Jamming': '₹299 – ₹599',
      'Hinges Replacement': '₹199 – ₹399',
      'New Door Installation': '₹899 – ₹1999',
      'Door Frame Repair': '₹499 – ₹999',
      'Sliding Door Issue': '₹399 – ₹899',
      'Other': '₹149 (inspection)',
    },
    'Lock & Handle Installation': {
      'New Lock Installation': '₹249 – ₹599',
      'Handle Replacement': '₹149 – ₹349',
      'Key Stuck / Broken': '₹199 – ₹499',
      'Digital Lock Setup': '₹499 – ₹999',
      'Other': '₹99 (inspection)',
    },
    'Furniture Assembly/Repair': {
      'Table/Chair Repair': '₹299 – ₹699',
      'Furniture Assembly (IKEA etc)': '₹799 – ₹1999',
      'Furniture Polishing': '₹999 – ₹4999',
      'Termite Damage Fix': '₹499 – ₹1499',
      'Other': '₹199 (inspection)',
    },
    'Bed/Sofa Repair': {
      'Sofa Leg Repair': '₹299 – ₹599',
      'Bed Support Fix': '₹399 – ₹899',
      'Hydraulic Bed Issue': '₹599 – ₹1499',
      'Sofa Cushion Replacement': '₹1499 – ₹4999',
      'Other': '₹249 (inspection)',
    },
    'Wardrobe/Cabinet Repair': {
      'Hinge Adjustment': '₹199 – ₹399',
      'Wardrobe Door Realignment': '₹299 – ₹699',
      'Shelf Addition': '₹399 – ₹899',
      'Broken Mirror Replace': '₹499 – ₹1499',
      'Other': '₹199 (inspection)',
    },
    'Kitchen Drawer Fix': {
      'Channel Replacement': '₹399 – ₹899',
      'Drawer Alignment': '₹199 – ₹399',
      'Basket Fix': '₹249 – ₹599',
      'Other': '₹99 (inspection)',
    },
    'Wood Polishing & Finish': {
      'Melamine Polish': '₹1499 – ₹4999',
      'PU Polish (Premium)': '₹2999 – ₹9999',
      'Normal Varnish': '₹999 – ₹2999',
      'Spirit Polish': '₹1299 – ₹3999',
      'Other': '₹299 (inspection)',
    },
    // Interior Detail
    'Modular Kitchen Design': {
      'Full Kitchen Design': '₹45000 – ₹250000',
      'Kitchen Remodeling': '₹15000 – ₹50000',
      'Cabinet Upgrades': '₹5999 – ₹14999',
      'Countertop Change': '₹4999 – ₹12999',
      'Consultation Visit': '₹499 (adjustable)',
    },
    'False Ceiling (POP/PVC)': {
      'POP False Ceiling (sq ft)': '₹95 – ₹150',
      'PVC False Ceiling (sq ft)': '₹75 – ₹120',
      'Gypsum Ceiling': '₹110 – ₹180',
      'Ceiling Repair / Patching': '₹999 – ₹4999',
      'Consultation': '₹299',
    },
    'Wallpaper Installation': {
      'Normal Wallpaper (roll)': '₹1199 – ₹2499',
      'Premium 3D Wallpaper': '₹2499 – ₹5999',
      'Old Wallpaper Removal': '₹499 – ₹1499',
      'Wall Preparation': '₹299 – ₹899',
    },
    'PVC Wall Panel Fitting': {
      'Panel Installation (sq ft)': '₹65 – ₹110',
      'Corner Beading Fix': '₹199 – ₹499',
      'Damaged Panel Replace': '₹499 – ₹1499',
    },
    // Painting Detail
    'Full House Painting (Int)': {
      '1 BHK Full Paint': '₹8999 – ₹15000',
      '2 BHK Full Paint': '₹14000 – ₹25000',
      '3 BHK Full Paint': '₹20000 – ₹40000',
      'Royal / Luxury Finish': '₹30000+',
    },
    'Exterior Wall Painting': {
      'External Full House': '₹12000 – ₹50000',
      'Weather Coat Application': '₹8000 – ₹20000',
      'Scaffolding Charges': '₹2000 – ₹5000',
    },
    'Single Room Painting': {
      'Standard Room': '₹2499 – ₹4999',
      'Premium Finish Room': '₹3999 – ₹7999',
      'Ceiling Painting': '₹999 – ₹1999',
    },
    'Texture & Stencil Design': {
      'Texture Wall (per wall)': '₹1999 – ₹5999',
      'Stencil Design': '₹999 – ₹2999',
      'Metallic Finish': '₹2499 – ₹6999',
    },
    'Waterproofing Treatment': {
      'Roof Waterproofing': '₹4999 – ₹15000',
      'Bathroom Seepage Fix': '₹2499 – ₹5999',
      'Wall Dampness Fix': '₹1499 – ₹4999',
    },
    'TV Unit & Wardrobe Design': {
      'TV Unit Design': '₹5000 – ₹15000',
      'Wardrobe Designing': '₹8000 – ₹25000',
      'Bookshelf Design': '₹3000 – ₹8000',
      'Crockery Unit': '₹4000 – ₹12000',
      'Consultation': '₹499',
    },
    'Wooden/Laminate Flooring': {
      'Wooden Flooring (sq ft)': '₹120 – ₹250',
      'Laminate Flooring (sq ft)': '₹80 – ₹180',
      'Floor Repair / Refinish': '₹999 – ₹4999',
      'Underlayment Fitting': '₹199 – ₹499',
    },
    'Lighting & Decoration': {
      'Chandelier Installation': '₹499 – ₹1499',
      'Cove Lighting Setup': '₹999 – ₹2999',
      'Spotlights Fitting': '₹299 – ₹899',
      'Decorative Wall Lights': '₹199 – ₹499',
      'Festive Lighting': '₹499 – ₹1999',
    },
    'Full Home Interior': {
      'Full Home Consultation': '₹999 (adjustable)',
      '1 BHK Full Interior': '₹99,000 – ₹3,00,000',
      '2 BHK Full Interior': '₹2,50,000 – ₹6,00,000',
      '3 BHK Full Interior': '₹5,00,000 – ₹12,00,000',
    },
    'Putty & Primer Work': {
      'Wall Putty (per sq ft)': '₹15 – ₹25',
      'Wall Primer (per sq ft)': '₹10 – ₹20',
      'Scraping Old Paint': '₹5 – ₹10',
      'Sanding & Finishing': '₹500 – ₹1500',
    },
    'Door & Window Polishing': {
      'Main Door Polish': '₹1499 – ₹3499',
      'Window Frame Polish': '₹499 – ₹999',
      'Furniture Touch-up': '₹299 – ₹899',
      'Spirit Polish': '₹999 – ₹2499',
    },
    'Metal/Gate Painting': {
      'Main Gate Painting': '₹1499 – ₹3999',
      'Grill Painting': '₹299 – ₹899',
      'Railing Painting': '₹499 – ₹1499',
      'Anti-Rust Coating': '₹399 – ₹999',
    },
    'Custom Furniture Making': {
      'Dining Table Making': '₹8000 – ₹20000',
      'Custom Wardrobe': '₹15000 – ₹45000',
      'Bed Making': '₹12000 – ₹30000',
      'Study Table': '₹3000 – ₹8000',
    },
  };

  void _showCompanyPicker() {
    final List<String> allCompanies = serviceCompanies[widget.serviceName] ?? ['Other'];
    List<String> filteredCompanies = List.from(allCompanies);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF162436),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Select Brand / Company',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Search brand...',
                        hintStyle: TextStyle(color: Colors.white38),
                        prefixIcon: Icon(Icons.search, color: Color(0xFF00D1FF)),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setModalState(() {
                          filteredCompanies = allCompanies
                              .where((company) => company.toLowerCase().contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredCompanies.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            filteredCompanies[index],
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: selectedCompany == filteredCompanies[index]
                              ? const Icon(Icons.check_circle, color: Color(0xFF00D1FF))
                              : null,
                          onTap: () {
                            setState(() {
                              selectedCompany = filteredCompanies[index];
                              isOtherCompanySelected = (selectedCompany == 'Other');
                              if (!isOtherCompanySelected) {
                                _customCompanyController.clear();
                              }
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00D1FF),
              onPrimary: Color(0xFF0D1B2E),
              surface: Color(0xFF162436),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF0D1B2E),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        customDate = picked;
        selectedDay = DateFormat('dd MMM, yyyy').format(picked);
      });
    }
  }

  @override
  void dispose() {
    _otherProblemController.dispose();
    _customCompanyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final problems = servicePrices[widget.serviceName]?.keys.toList() ?? ['General Issue', 'Other'];
    final companies = serviceCompanies[widget.serviceName] ?? ['Other'];
    final bool showCompanyPicker = !(companies.length == 1 && companies[0] == 'N/A');

    // Auto-set company for services that don't need brand selection
    if (!showCompanyPicker && selectedCompany == null) {
      selectedCompany = 'FixooIndia Team';
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.serviceName,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Select Company (hidden for cleaning services)
              if (showCompanyPicker) ...[
              const Text(
                'Select Company',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: _showCompanyPicker,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isOtherCompanySelected ? const Color(0xFF00D1FF).withOpacity(0.3) : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedCompany ?? 'Choose Brand / Company',
                        style: TextStyle(
                          color: selectedCompany == null ? Colors.white38 : Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down, color: Color(0xFF00D1FF)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),

              if (isOtherCompanySelected)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFF00D1FF).withOpacity(0.3)),
                  ),
                  child: TextField(
                    controller: _customCompanyController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Type your Brand / Company name...',
                      hintStyle: TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
              const SizedBox(height: 15),
              ],

              // 2. Select Problem
              const Text(
                'Select Problems',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: problems.map((problem) {
                  bool isSelected = selectedProblems.contains(problem);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedProblems.remove(problem);
                          if (problem == 'Other') isOtherProblemSelected = false;
                        } else {
                          selectedProblems.add(problem);
                          if (problem == 'Other') isOtherProblemSelected = true;
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF00D1FF) : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF00D1FF) : Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Text(
                        problem,
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF0D1B2E) : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              if (isOtherProblemSelected)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFF00D1FF).withOpacity(0.3)),
                  ),
                  child: TextField(
                    controller: _otherProblemController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Please describe your problem here...',
                      hintStyle: TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),

              // 3. Description
              const Text(
                'Description',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  _buildDescription(),
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                ),
              ),
              const SizedBox(height: 30),

              // 4. Price Overview
              const Text(
                'Price Overview',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D1FF).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFF00D1FF).withOpacity(0.2)),
                ),
                child: Column(
                  children: selectedProblems.isEmpty 
                    ? [const Center(child: Text('Please select problems to see pricing', style: TextStyle(color: Colors.white38)))]
                    : selectedProblems.map((problem) {
                        String price = servicePrices[widget.serviceName]?[problem] ?? '₹99 (inspection)';
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  problem,
                                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                                ),
                              ),
                              Text(
                                price,
                                style: const TextStyle(
                                  color: Color(0xFF00D1FF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),
              const SizedBox(height: 30),

              // 5. Select Day
              const Text(
                'Select Day',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDay = 'Today';
                          customDate = null;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: selectedDay == 'Today' ? const Color(0xFF00D1FF) : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selectedDay == 'Today' ? const Color(0xFF00D1FF) : Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Today',
                            style: TextStyle(
                              color: selectedDay == 'Today' ? const Color(0xFF0D1B2E) : Colors.white70,
                              fontWeight: selectedDay == 'Today' ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: selectedDay != 'Today' ? const Color(0xFF00D1FF) : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selectedDay != 'Today' ? const Color(0xFF00D1FF) : Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: selectedDay != 'Today' ? const Color(0xFF0D1B2E) : const Color(0xFF00D1FF),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                selectedDay == 'Today' ? 'Pick Date' : selectedDay,
                                style: TextStyle(
                                  color: selectedDay != 'Today' ? const Color(0xFF0D1B2E) : Colors.white70,
                                  fontWeight: selectedDay != 'Today' ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // 6. Address
              const Text(
                'Address',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF00D1FF)),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Location',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _currentAddress,
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LocationPickerScreen()),
                        );
                        if (result != null && mounted) {
                          setState(() => _currentAddress = result as String);
                        }
                      },
                      child: const Text('Change', style: TextStyle(color: Color(0xFF00D1FF))),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Book Now Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    if (selectedCompany == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a company/brand first')),
                      );
                      return;
                    }
                    if (isOtherCompanySelected && _customCompanyController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please type your brand name')),
                      );
                      return;
                    }
                    if (selectedProblems.isEmpty && !isOtherProblemSelected) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select at least one problem')),
                      );
                      return;
                    }

                    // ADD BOOKING TO PROVIDER
                    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
                    if (selectedDay != null) {
                      try {
                        // Get current location for map
                        Position? position;
                        try {
                          position = await Geolocator.getCurrentPosition(
                            desiredAccuracy: LocationAccuracy.high,
                            timeLimit: const Duration(seconds: 5),
                          );
                        } catch (e) {
                          debugPrint('Location error: $e');
                        }

                        // API Integration Point: Save Booking to Supabase
                        final bookingId = await SupabaseService.createBooking(
                          serviceName: widget.serviceName,
                          brand: isOtherCompanySelected ? _customCompanyController.text : (selectedCompany ?? 'N/A'),
                          problems: selectedProblems,
                          scheduledDate: selectedDay!,
                          address: _currentAddress,
                          latitude: position?.latitude,
                          longitude: position?.longitude,
                        );

                        // Also update local state for immediate UI update
                        final newBooking = Booking(
                          id: bookingId,
                          serviceName: widget.serviceName,
                          brand: isOtherCompanySelected ? _customCompanyController.text : (selectedCompany ?? 'N/A'),
                          problems: List.from(selectedProblems),
                          date: selectedDay!,
                          bookingTime: DateTime.now(),
                          status: 'Pending',
                        );
                        // 2. Add to Local Provider
                        bookingProvider.addBooking(newBooking);

                        // 3. Add to Notification Provider
                        final notifProvider = Provider.of<NotificationProvider>(context, listen: false);
                        notifProvider.addNotification(AppNotification(
                          title: 'Booking Confirmed!',
                          body: 'Your ${widget.serviceName} booking for ${selectedDay} is confirmed.',
                          time: 'Just now',
                          icon: LucideIcons.calendarCheck,
                        ));

                        _showSuccessDialog(bookingId);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Booking failed: ${e.toString()}')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a date')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D1FF),
                    foregroundColor: const Color(0xFF0D1B2E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(String? bookingId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF162436),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF00D1FF), size: 80),
            const SizedBox(height: 20),
            const Text(
              'Booking Successful!',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Your request for ${widget.serviceName} has been received.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TrackingScreen(
                        serviceName: widget.serviceName,
                        brand: isOtherCompanySelected ? _customCompanyController.text : selectedCompany!,
                        bookingId: bookingId,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D1FF),
                  foregroundColor: const Color(0xFF0D1B2E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Track your Technician', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Go to Home', style: TextStyle(color: Colors.white70)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildDescription() {
    String desc = '';
    if (selectedCompany != null) {
      if (isOtherCompanySelected && _customCompanyController.text.isNotEmpty) {
        desc += 'Brand: ${_customCompanyController.text}. ';
      } else {
        desc += 'Brand: $selectedCompany. ';
      }
    }
    
    List<String> displayProblems = List.from(selectedProblems);
    if (isOtherProblemSelected) {
      displayProblems.remove('Other');
      if (_otherProblemController.text.isNotEmpty) {
        displayProblems.add('Custom: ${_otherProblemController.text}');
      }
    }

    if (displayProblems.isEmpty) {
      return desc + 'Please select problems above to see details.';
    }

    return desc + 'Selected Problems: ${displayProblems.join(", ")}. Scheduled for $selectedDay.';
  }
}
