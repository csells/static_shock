import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';

import 'package:args/command_runner.dart';
import 'package:mason/mason.dart';
import 'package:static_shock/static_shock.dart';

final _log = Logger(level: Level.verbose);

void main(List<String> arguments) {
  final runner = CommandRunner("shock", "A static site generator, written in Dart.")
    ..addCommand(CreateCommand())
    ..addCommand(BuildCommand())
    ..addCommand(ServeCommand())
    ..addCommand(ValidateCommand())
    ..run(arguments);

  // TODO:
}

class CreateCommand extends Command {
  @override
  final name = "create";

  @override
  final description = "Creates a new static site project at the desired location.";

  @override
  Future<void> run() async {
    _log.info("Creating a new Static Stock project...");

    final workingDirectory = Directory.current;
    _log.detail("Current directory: ${workingDirectory.path}");

    final projectConfiguration = await _promptForConfiguration();

    final generator = await MasonGenerator.fromBrick(
      Brick.path("/Users/admin/Projects/static_shock/static_shock/packages/static_shock_cli/templates/new_project/"),
    );
    final target = DirectoryGeneratorTarget(Directory.current);

    await generator.generate(target, vars: projectConfiguration);

    _log.success("Successfully created a new Static Shock project!");
  }

  Future<Map<String, dynamic>> _promptForConfiguration() async {
    final vars = <String, dynamic>{};

    vars["project_name"] = _log.prompt("Project name (e.g., 'static_shock_docs')");
    if (vars["project_name"].trim().isEmpty) {
      _log.err("Your project name can't be blank");
      exit(ExitCode.ioError.code);
    }

    vars["project_description"] = _log.prompt("Project description (e.g., 'Documentation for Static Shock')");

    return vars;
  }
}

class BuildCommand extends Command {
  @override
  final name = "build";

  @override
  final description = "Builds a deployable static website by copying and transforming all source files.";

  @override
  Future<void> run() async {
    // TODO: run a shell command that runs the main dart file in the current directory
  }
}

class ServeCommand extends Command {
  @override
  final name = "serve";

  @override
  final description =
      "Builds a deployable static website, serves it via localhost, and updates the website whenever the source files change.";

  @override
  Future<void> run() async {
    print("Serving a static site!");

    var handler = const Pipeline() //
        .addMiddleware(logRequests()) //
        .addHandler(
          createStaticHandler(
            'website_build',
            defaultDocument: 'index.html',
          ),
        );

    var server = await shelf_io.serve(handler, 'localhost', 4000);

    // Enable content compression
    server.autoCompress = true;

    print('Serving at http://${server.address.host}:${server.port}');
  }
}

class ValidateCommand extends Command {
  @override
  final name = "validate";

  @override
  final description = "Inspects the current working directory and validates its structure as a Static Shock project.";

  @override
  Future<void> run() async {
    // TODO:
    print("Validating Static Shock project!");
  }
}