import 'package:flutter/material.dart';
import 'package:frontend/providers/locale_translationProvider.dart';
import 'package:frontend/screens/map/network_utility.dart';
import 'package:frontend/screens/map/place_autocomplete_response.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'autocomplete_prediction.dart';
import 'location_list.dart';

class SearchLocationScreen extends StatefulWidget {
  const SearchLocationScreen({super.key});

  @override
  State<SearchLocationScreen> createState() => SearchLocationScreenState();
}

class SearchLocationScreenState extends State<SearchLocationScreen> {

  String apiKey = "API_KEY_HERE";

  List<AutocompletePrediction> placePredictions = [];

  late TextEditingController _searchController;
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  void placeAutocomplete(String query) async {
    Uri uri = Uri.https(
      "maps.googleapis.com",
      'maps/api/place/autocomplete/json',
      {
        "input": query,
        "key": apiKey,
      }
    );
    String? response = await NetworkUtility.fetchUrl(uri);

    if (response != null) {
      PlaceAutocompleteResponse result = PlaceAutocompleteResponse.parseAutocompleteResult(response);
      if (result.predictions != null) {
        setState(() {
          placePredictions = result.predictions!;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 50,),
          ClipRRect(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                border: Border.fromBorderSide(BorderSide(color: Colors.black, width: 0.5)),
                color: Colors.white
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop (context);
                    },
                  ),
                  suffixIcon: _searchText.isNotEmpty ? IconButton( 
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                      });
                    },
                    icon: const Icon(Icons.cancel_outlined)
                  ): null,
                  border: InputBorder.none,
                  hintText: TranslationService().translate('search...'),
                  contentPadding: const EdgeInsets.all(10)
                ),
                onChanged: (value) {
                  placeAutocomplete(value);
                },
              ),
            )
          ),
          Expanded(
            child: ListView.builder(
              itemCount: placePredictions.length,
              itemBuilder: (context, index) => LocationList(
                location: placePredictions[index].description!,
                press: () async{
                  List<Location> locations = await locationFromAddress(placePredictions[index].description.toString());
                  LatLng pos = LatLng(locations.last.latitude, locations.last.longitude);
                  Navigator.pop (context, pos);
                }
              )
            ),
          )
        ],
      ),
    );
  }
}