import 'dart:io';

import 'package:static_shock/src/files.dart';
import 'package:static_shock/src/finishers.dart';
import 'package:static_shock/src/templates/components.dart';
import 'package:static_shock/src/templates/layouts.dart';

import 'assets.dart';
import 'pages.dart';

/// A pipeline that runs a series of steps to generate a static website.
abstract class StaticShockPipeline {
  /// Adds the given [picker] to the pipeline, which selects files that will
  /// be pushed through the pipeline.
  void pick(Picker picker);

  /// Adds the given [excluder] to the pipeline, which prevents files from entering
  /// the pipeline, even when they're picked by a [Picker].
  ///
  /// For example:
  ///
  ///     pipeline
  ///       .pick(DirectoryPicker.parse("images"))
  ///       .exclude(FilePicker.parse("**/.DS_Store");
  ///
  void exclude(Excluder excluder);

  /// Adds the given [AssetTransformer] to the pipeline, which copies, alters, and
  /// saves assets from the source set to the build set.
  void transformAssets(AssetTransformer transformer);

  /// Adds the given [PageLoader] to the pipeline, which reads desired files into
  /// [Page] objects, which may then be processed by [PageTransformer]s and
  /// [PageRenderer]s.
  void loadPages(PageLoader loader);

  /// Adds the given [PageTransformer] to the pipeline, which alters [Page]s loaded
  /// by [PageLoader]s, before the [Page] is rendered by a [PageRenderer].
  void transformPages(PageTransformer transformer);

  /// Adds the given [PageRenderer] to the pipeline, which takes a [Page] and serializes
  /// that [Page] to an HTML page in the build set.
  void renderPages(PageRenderer renderer);

  /// Adds the given [Finisher] to the pipeline, which runs after all [Page]s are
  /// loaded, indexed, transformed, and rendered.
  ///
  /// A [Finisher] might be used, for example, to generate an RSS feed, which requires
  /// knowledge of all pages in the static site.
  void finish(Finisher finisher);
}

/// Information and file system access that's provided to various pipeline actors
/// and also provided to plugins.
class StaticShockPipelineContext {
  StaticShockPipelineContext(this._sourceDirectory);

  final Directory _sourceDirectory;

  /// Maps a given [relativePath] to a fully-resolved file system [Directory].
  Directory resolveSourceDirectory(DirectoryRelativePath relativePath) {
    return _sourceDirectory.subDir([relativePath.value]);
  }

  /// Maps a given [relativePath] to a fully-resolved file system [File].
  File resolveSourceFile(FileRelativePath relativePath) {
    return _sourceDirectory.descFile([relativePath.value]);
  }

  /// An index of [Page]s loaded into the pipeline.
  final pagesIndex = PagesIndex();

  /// Returns the [Layout] template from the given file [path].
  Layout? getLayout(FileRelativePath path) => _layouts[path];
  final _layouts = <FileRelativePath, Layout>{};

  /// Adds the given [layout] to the pipeline.
  void putLayout(Layout layout) {
    _layouts[layout.path] = layout;
  }

  /// All components loaded into the pipeline.
  Map<String, Component> get components => Map<String, Component>.from(_components);
  final _components = <String, Component>{};

  /// Returns the [Component] in the file with the given [name].
  Component? getComponent(String name) => _components[name];

  /// Adds the given [Component] to the pipeline.
  void putComponent(String name, Component component) {
    _components[name] = component;
  }
}
