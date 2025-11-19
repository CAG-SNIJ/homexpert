import 'package:flutter/material.dart';
import '../widgets/homepage_header.dart';
import '../widgets/homepage_hero.dart';
import '../widgets/homepage_explore_section.dart';
import '../widgets/homepage_properties_section.dart';
import '../widgets/homepage_features_section.dart';
import '../widgets/homepage_articles_section.dart';
import '../widgets/homepage_cta_section.dart';
import '../widgets/homepage_footer.dart';
import '../widgets/floating_chatbot_button.dart';

class HomepageScreen extends StatelessWidget {
  const HomepageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          const SliverToBoxAdapter(
            child: HomepageHeader(),
          ),
          
          // Hero Section
          const SliverToBoxAdapter(
            child: HomepageHero(),
          ),
          
          // Explore Near You Section
          const SliverToBoxAdapter(
            child: HomepageExploreSection(),
          ),
          
          // Handpicked Properties Section
          const SliverToBoxAdapter(
            child: HomepagePropertiesSection(),
          ),
          
          // Choose Us / Features Section
          const SliverToBoxAdapter(
            child: HomepageFeaturesSection(),
          ),
          
          // Articles Section
          const SliverToBoxAdapter(
            child: HomepageArticlesSection(),
          ),
          
          // CTA Section
          const SliverToBoxAdapter(
            child: HomepageCTASection(),
          ),
          
          // Footer
          const SliverToBoxAdapter(
            child: HomepageFooter(),
          ),
        ],
      ),
      floatingActionButton: const FloatingChatbotButton(),
    );
  }
}

