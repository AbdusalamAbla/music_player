import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:music_player/pages/page_manage.dart';

const ROUTE_MAIN='/';

const ROUTE_LOCALMUSIC='/localMusic';

const ROUTE_NETMUSIC='/netMusic';

const ROUTE_SETTING='/setting';

final Map<String,WidgetBuilder> routes={

  ROUTE_MAIN:(context)=>HomePage(),

  ROUTE_SETTING:(context)=>SettingPage()

};