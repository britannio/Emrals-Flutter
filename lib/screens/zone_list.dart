import 'package:cached_network_image/cached_network_image.dart';
import 'package:emrals/data/zone_api.dart';
import 'package:emrals/models/zone.dart';
import 'package:emrals/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:location/location.dart';

class ZoneListScreen extends StatefulWidget {
  @override
  _ZoneList createState() => _ZoneList();
}

class _ZoneList extends State<ZoneListScreen> with AutomaticKeepAliveClientMixin{
  @override
  bool get wantKeepAlive => true;
  final int limit = 50;
  PagewiseLoadController<Zone> pageLoadController;
  String searchTerm = "";
  bool searchActive = false;
  ZoneSortType sortType = ZoneSortType.RECENT;
  var currentLocation = <String, double>{};
  var location = Location();
  final ZoneApi zoneApi = ZoneApi();

  @override
  void initState() {
    super.initState();
    pageLoadController = PagewiseLoadController(
      pageSize: limit,
      pageFuture: (int batch) => zoneApi.getZones(
            limit: limit,
            offset: limit * batch,
            zoneSortType: sortType,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FloatingActionButton(
            child: Icon(
              Icons.sort,
              color: Colors.white,
            ),
            onPressed: (() {
              showDialog(
                  context: context,
                  builder: (ctx) => ZoneSortDialog(
                        initialSort: sortType,
                      )).then((d) {
                setState(() {
                  sortType = d;
                  pageLoadController = PagewiseLoadController(
                    pageSize: limit,
                    pageFuture: (int batch) => zoneApi.getZones(
                          limit: limit,
                          offset: limit * batch,
                          zoneSortType: sortType,
                        ),
                  );
                });
              });
            }),
          ),
          /* SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                searchActive = true;
              });
            },
            child: Icon(
              Icons.search,
              color: Colors.white,
            ),
          ), */
        ],
      ),
      /* appBar: searchActive
          ? PreferredSize(
              child: Container(
                padding: EdgeInsets.only(left: 10),
                color: darkGrey,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Search...",
                          labelStyle: TextStyle(color: Colors.white30),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                        ),
                        onChanged: (s) {
                          setState(() {
                            searchTerm = s;
                            if (s.isEmpty) _handleRefresh();
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          searchTerm = "";
                          searchActive = false;
                          zones = [];
                          _progressBarActive = true;
                          fetchZones(0, 10, sortType);
                        });
                      },
                    )
                  ],
                ),
              ),
              preferredSize: Size.fromHeight(50))
          : null, */
      body: RefreshIndicator(
        onRefresh: () async => pageLoadController.reset(),
        child: PagewiseListView(
          padding: const EdgeInsets.symmetric(vertical: 6),
          pageLoadController: pageLoadController,
          noItemsFoundBuilder: (BuildContext context) => Center(
                child: Text('No zones found.'),
              ),
          loadingBuilder: (BuildContext context) =>
              Center(child: CircularProgressIndicator()),
          itemBuilder: (BuildContext context, Zone zone, int index) =>
              ZoneListItem(zone: zone),
        ),
      ),
    );
  }
}

class ZoneListItem extends StatefulWidget {
  final Zone zone;

  ZoneListItem({this.zone});

  @override
  _ZoneListItemState createState() => _ZoneListItemState();
}

class _ZoneListItemState extends State<ZoneListItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Material(
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 4,
        child: InkWell(
          onTap: null,
          child: IntrinsicHeight(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      widget.zone.image != null
                          ? CachedNetworkImage(
                              placeholder: (context, _) => Image.asset(
                                    'assets/placeholder.png',
                                    fit: BoxFit.cover,
                                  ),
                              imageUrl: widget.zone.image,
                              errorWidget: (context, _, error) =>
                                  Icon(Icons.error),
                            )
                          : Container(
                              alignment: Alignment.center,
                              child: Text('No Image'),
                            ),
                      CachedNetworkImage(
                        height: 30,
                        imageUrl: widget.zone.flag,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 10),
                      Text(
                        widget.zone.city,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: emralsColor().shade50),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Image.asset("assets/greene.png",
                              width: 18, height: 18),
                          SizedBox(width: 5),
                          Text(
                            "${widget.zone.emralsAmount} emrals",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: emralsColor()[1000],
                            size: 15,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "${widget.zone.subscriberCount} sponsors",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.camera_alt,
                            color: emralsColor()[1500],
                            size: 15,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "${widget.zone.reportCount} reports",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Image.asset("assets/trophy.png",
                              width: 15,
                              height: 15,
                              color: emralsColor()[1400]),
                          SizedBox(width: 5),
                          Text(
                            "${widget.zone.cleanupCount} cleanups",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      SizedBox(height: 10),
                      RaisedButton(
                        padding: EdgeInsets.zero,
                        shape: StadiumBorder(),
                        color: emralsColor()[1000],
                        onPressed: () {
                          _showModal(widget.zone);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "FUND",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showModal(zone) {
    Future<void> future = showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData(canvasColor: Colors.transparent),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.directions_walk),
                title: Text('100 EMRALS / month ' + zone.city),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.directions_run),
                title: Text('200 EMRALS / month ' + zone.city),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.directions_bike),
                title: Text('500 EMRALS / month ' + zone.city),
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
    future.then((void value) => _closeModal(value));
  }

  void _closeModal(void value) {
    print('modal closed');
  }
}

class ZoneSortDialog extends StatefulWidget {
  final ZoneSortType initialSort;

  ZoneSortDialog({this.initialSort});

  @override
  _ZoneSortDialogState createState() => _ZoneSortDialogState();
}

class _ZoneSortDialogState extends State<ZoneSortDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Sort Zones"),
      content: SingleChildScrollView(
        child: Column(
          children: ZoneSortType.values.map((z) {
            return ListTile(
              onTap: () {
                Navigator.pop(context, z);
              },
              title: Text(z.toString().split(".")[1]),
              trailing: widget.initialSort == z
                  ? Icon(
                      Icons.check,
                      color: emralsColor(),
                    )
                  : Container(
                      width: 0,
                      height: 0,
                    ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
