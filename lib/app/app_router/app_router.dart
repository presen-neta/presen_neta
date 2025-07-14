import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:presen_neta/features/result/presentation/page/result_page.dart';
import 'package:presen_neta/features/start/presentation/page/start_page.dart';

/// アプリ全体のルーティングを管理するクラス。
///
/// [appRouter] を用いて、各ページへのルートを集中管理する。

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'start',
      builder: (context, state) => const StartPage(),
    ),
    GoRoute(
      path: '/result',
      name: 'result',
      builder: (context, state) => const ResultPage(),
    ),
  ],
  errorBuilder:
      (context, state) => const Scaffold(
        body: Center(
          child: Text('Page Not Found'),
        ),
      ),
);
