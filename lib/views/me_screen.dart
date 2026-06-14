import 'package:flutter/material.dart';
import '../core/stylesheet.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Stylesheet.primary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 1, color: Color(0xFFE6E9ED)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 프로필 아바타
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Stylesheet.themeLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 닉네임 행
                  Row(
                    children: [
                      const Text(
                        '김루난님',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Stylesheet.label,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '닉네임 변경',
                        style: TextStyle(fontSize: 14, color: Stylesheet.theme),
                      ),
                      const Spacer(),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6E9ED),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Center(
                          child: Text(
                            'G',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // 토큰 사용량
                  const Row(
                    children: [
                      Text(
                        '이번 주 토큰 사용량',
                        style: TextStyle(fontSize: 16, color: Stylesheet.label),
                      ),
                      Spacer(),
                      Text(
                        '33%',
                        style: TextStyle(fontSize: 16, color: Stylesheet.label),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      value: 0.33,
                      minHeight: 8,
                      backgroundColor: Stylesheet.themeLight,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Stylesheet.theme),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 문의하기
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '문의하기',
                      style: TextStyle(
                          fontSize: 13, color: Stylesheet.secondaryLabel),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 요금
                  const Row(
                    children: [
                      Text(
                        '요금',
                        style: TextStyle(
                            fontSize: 16, color: Stylesheet.label),
                      ),
                      Spacer(),
                      Text(
                        '월 5,000원',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Stylesheet.theme,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFE6E9ED)),
            const Spacer(),
            // 회원 탈퇴
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '회원 탈퇴',
                  style: TextStyle(
                      fontSize: 13, color: Stylesheet.secondaryLabel),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
