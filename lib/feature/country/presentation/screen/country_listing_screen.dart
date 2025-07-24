import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_practice_project/core/presentation/states/loader_state.dart';
import 'package:sqflite_practice_project/core/utils/debouncer.dart';
import 'package:sqflite_practice_project/feature/country/domain/models/country_model.dart';
import 'package:sqflite_practice_project/feature/country/presentation/notifier/country_listing_notifier.dart';
import 'package:sqflite_practice_project/feature/country/presentation/widgets/country_item.dart';

class CountryListingScreen extends ConsumerStatefulWidget {
  const CountryListingScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CountryListingScreenState();
}

class _CountryListingScreenState extends ConsumerState<CountryListingScreen> {
  late TextEditingController controller;
  late FocusNode focusNode;
  late Debouncer debouncer;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    _init();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(countryListingNotifierProvider.notifier)
          .searchCountries(context);
    });
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Theme.of(context).colorScheme.surface,
        systemNavigationBarColor: Theme.of(context).colorScheme.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Countries",
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                ref
                    .read(countryListingNotifierProvider.notifier)
                    .refreshCountries();
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),

              /// Search container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            Icon(
                              Icons.search,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: controller,
                                focusNode: focusNode,
                                style: Theme.of(context).textTheme.bodyMedium,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Search Countries',
                                  hintStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                                onChanged: (v) {
                                  onSearch(query: v);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (controller.text.isNotEmpty)
                              InkWell(
                                onTap: () {
                                  controller.clear();
                                  onSearch();
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  "Countries",
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Loading indicator
              Consumer(
                builder: (_, ref, __) {
                  bool isSearching = ref.watch(
                    countryListingNotifierProvider.select((s) => s.isSearching),
                  );
                  return SizedBox(
                    height: 3,
                    width: double.infinity,
                    child: isSearching
                        ? LinearProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surface,
                          )
                        : const SizedBox.shrink(),
                  );
                },
              ),

              Expanded(
                child: Consumer(
                  builder: (_, ref, _) {
                    final state = ref.watch(countryListingNotifierProvider);
                    final countries = state.countries;
                    final loaderState = state.loaderState;
                    final hasMoreData = state.hasMoreData;
                    final isLoadingMore = state.isLoadingMore;

                    return loaderState is StError && countries.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Oops, something went wrong!',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Failed to load countries. Please try again.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    ref
                                        .read(
                                          countryListingNotifierProvider
                                              .notifier,
                                        )
                                        .searchCountries(context);
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : countries.isEmpty && !state.isSearching
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No countries found!',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  state.currentQuery?.isNotEmpty == true
                                      ? 'No countries found for "${state.currentQuery}".'
                                      : 'No countries available.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          )
                        : NotificationListener<ScrollNotification>(
                            onNotification: (ScrollNotification scrollInfo) {
                              if (scrollInfo is ScrollEndNotification &&
                                  scrollController.position.extentAfter < 200 &&
                                  hasMoreData &&
                                  !isLoadingMore &&
                                  !state.isSearching) {
                                ref
                                    .read(
                                      countryListingNotifierProvider.notifier,
                                    )
                                    .loadMoreCountries();
                              }
                              return false;
                            },
                            child: RefreshIndicator(
                              onRefresh: () => ref
                                  .read(countryListingNotifierProvider.notifier)
                                  .refreshCountries(),
                              child: CustomScrollView(
                                controller: scrollController,
                                slivers: [
                                  /// Countries list
                                  SliverList.separated(
                                    itemBuilder: (ctx, index) {
                                      Country country = countries[index];
                                      return CountryItem(
                                        title: country.commonName,
                                        subtitle: country.officialName,
                                        onTap: () {
                                          _onCountrySelected(country);
                                        },
                                      );
                                    },
                                    separatorBuilder: (_, __) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Divider(
                                        height: 1,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.outline.withOpacity(0.2),
                                      ),
                                    ),
                                    itemCount: countries.length,
                                  ),

                                  // Loading more indicator
                                  if (isLoadingMore)
                                    SliverToBoxAdapter(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ),

                                  const SliverToBoxAdapter(
                                    child: SizedBox(height: 32),
                                  ),
                                ],
                              ),
                            ),
                          );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onSearch({String? query}) {
    debouncer.run(() {
      ref
          .read(countryListingNotifierProvider.notifier)
          .searchCountries(context, query: query);
    });
  }

  void _onCountrySelected(Country country) {

  }

  void _init() {
    debouncer = Debouncer(milliseconds: 600);
    controller = TextEditingController();
    focusNode = FocusNode();
    scrollController = ScrollController();
  }

  void _dispose() {
    debouncer.dispose();
    controller.dispose();
    focusNode.dispose();
    scrollController.dispose();
  }
}
