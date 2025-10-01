// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$booksByStatusHash() => r'093272e4900cdc33e11d4de882cb63891ca30cd9';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [booksByStatus].
@ProviderFor(booksByStatus)
const booksByStatusProvider = BooksByStatusFamily();

/// See also [booksByStatus].
class BooksByStatusFamily extends Family<AsyncValue<List<Book>>> {
  /// See also [booksByStatus].
  const BooksByStatusFamily();

  /// See also [booksByStatus].
  BooksByStatusProvider call(
    BookStatus status,
  ) {
    return BooksByStatusProvider(
      status,
    );
  }

  @override
  BooksByStatusProvider getProviderOverride(
    covariant BooksByStatusProvider provider,
  ) {
    return call(
      provider.status,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'booksByStatusProvider';
}

/// See also [booksByStatus].
class BooksByStatusProvider extends AutoDisposeFutureProvider<List<Book>> {
  /// See also [booksByStatus].
  BooksByStatusProvider(
    BookStatus status,
  ) : this._internal(
          (ref) => booksByStatus(
            ref as BooksByStatusRef,
            status,
          ),
          from: booksByStatusProvider,
          name: r'booksByStatusProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$booksByStatusHash,
          dependencies: BooksByStatusFamily._dependencies,
          allTransitiveDependencies:
              BooksByStatusFamily._allTransitiveDependencies,
          status: status,
        );

  BooksByStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.status,
  }) : super.internal();

  final BookStatus status;

  @override
  Override overrideWith(
    FutureOr<List<Book>> Function(BooksByStatusRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BooksByStatusProvider._internal(
        (ref) => create(ref as BooksByStatusRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Book>> createElement() {
    return _BooksByStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BooksByStatusProvider && other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin BooksByStatusRef on AutoDisposeFutureProviderRef<List<Book>> {
  /// The parameter `status` of this provider.
  BookStatus get status;
}

class _BooksByStatusProviderElement
    extends AutoDisposeFutureProviderElement<List<Book>> with BooksByStatusRef {
  _BooksByStatusProviderElement(super.provider);

  @override
  BookStatus get status => (origin as BooksByStatusProvider).status;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
