# Main build script for ImagineUI-Win
# Requires Python 3.10.0 or later.

import sys
import argparse
import subprocess
import json
import inspect

from pathlib import Path
from dataclasses import dataclass
from enum import Enum, unique
from typing import Any, Callable, List, Optional, TypeVar
from os import PathLike

win32_debug_args = ["-Xswiftc", "-g", "-Xswiftc", "-debug-info-format=codeview", "-Xlinker", "-debug"]


def make_argparser() -> argparse.ArgumentParser:
    # Argument parser with support for specifying default subcommand parser
    # https://stackoverflow.com/a/37593636
    class DefaultSubcommandArgParse(argparse.ArgumentParser):
        __default_subparser = None

        def set_default_subparser(self, name):
            self.__default_subparser = name

        def _parse_known_args(self, arg_strings, *args, **kwargs):
            in_args = set(arg_strings)
            d_sp = self.__default_subparser
            if d_sp is not None and not {'-h', '--help'}.intersection(in_args):
                for x in self._subparsers._actions:
                    subparser_found = (
                            isinstance(x, argparse._SubParsersAction) and in_args.intersection(
                        x._name_parser_map.keys())
                    )
                    if subparser_found:
                        break
                else:
                    # insert default in first position, this implies no
                    # global options without a sub_parsers specified
                    arg_strings = [d_sp] + arg_strings
            return super(DefaultSubcommandArgParse, self)._parse_known_args(
                arg_strings, *args, **kwargs
            )

    def add_target_arg(parser: argparse.ArgumentParser):
        parser.add_argument('-t', '--target',
                            type=str,
                            dest='target',
                            help="Optional target to build/test/run against. Must be one of the targets specified in Package.swift.")

    def add_executable_arg(parser: argparse.ArgumentParser):
        parser.add_argument('executable',
                            type=str,
                            default=None,
                            nargs='?',
                            help="The executable to run.")

    def add_manifest_arg(parser: argparse.ArgumentParser):
        parser.add_argument('-m', '--manifest-path',
                            type=Path,
                            dest='manifest_path',
                            default=None,
                            help="Path to a .manifest file to use when building .exe targets. If not provided, a path of the form "
                                 "'Sources\\<target-name>\\<target-name>.exe.manifest' will be assumed. Not used if 'target' is not an executable target.")

    def add_common_args(parser: argparse.ArgumentParser):
        parser.add_argument('-c', '--configuration',
                            type=str,
                            dest='configuration',
                            default='debug',
                            help="Build configuration to use. Can either be 'debug' or 'release'. Defaults to 'debug'.")

        parser.add_argument('-d',
                            action='append',
                            type=str,
                            dest='definitions',
                            help="A list of -D parameters to pass to -Xswiftc during compilation. Used to enable/disable '#if <DEFINITION_NAME>' in Swift code.")

    argparser = DefaultSubcommandArgParse(description='Builds ImagineUI-Win and/or sample project.')
    argparser.set_default_subparser('build')

    subparsers = argparser.add_subparsers(dest='command')

    build_parser = subparsers.add_parser('build', help='Facilitates running builds of Swift targets on Windows.')
    test_parser = subparsers.add_parser('test', help='Facilitates running tests of Swift targets on Windows.')
    run_parser = subparsers.add_parser('run', help='Facilitates running executable targets on Windows.')

    add_common_args(test_parser)
    add_common_args(build_parser)
    add_common_args(run_parser)

    add_target_arg(build_parser)
    add_target_arg(run_parser)
    add_manifest_arg(build_parser)
    add_manifest_arg(run_parser)
    add_executable_arg(run_parser)

    return argparser


def toSwiftCDefList(definitions: list[str] | None) -> list[str]:
    if definitions is None:
        return []

    for d in definitions:
        yield "-Xswiftc"
        yield f"-D{d}"

# Arguments for a build command.
@dataclass
class BuildCommandArgs:
    target_name: str | None
    config: str
    manifest_path: Path | None
    definitions: list[str] | None

    def swift_build_args(self) -> List[str]:
        args = []

        if self.target_name is not None:
            args.extend(['--target', self.target_name])

        args.extend(['--configuration', self.config, *win32_debug_args, *toSwiftCDefList(self.definitions)])

        return args


# Arguments for a run command.
@dataclass
class RunCommandArgs:
    target_name: str | None
    executable_name: str | None
    config: str
    manifest_path: Path | None
    definitions: list[str] | None

    def swift_build_args(self) -> List[str]:
        args = []

        if self.target_name is not None:
            args.extend(['--target', self.target_name])

        args.extend(['--configuration', self.config, *win32_debug_args, *toSwiftCDefList(self.definitions)])

        return args

    def swift_run_args(self) -> List[str]:
        args = []

        if self.executable_name is not None:
            args.append(self.executable_name)

        args.extend(['--configuration', self.config, *win32_debug_args, *toSwiftCDefList(self.definitions)])

        return args


# Arguments for a test command.
@dataclass
class TestCommandArgs:
    config: str
    definitions: list[str] | None

    def swift_test_args(self) -> List[str]:
        return ['--configuration', self.config, *win32_debug_args, *toSwiftCDefList(self.definitions)]


# Settings for post-build process.
@dataclass
class PostBuildSettings:
    exe_path: Path
    manifest_path: Path


@unique
class SwiftTargetType(str, Enum):
    REGULAR = 'regular'
    EXECUTABLE = 'executable'


# A Swift target declared in a Package.swift
class SwiftTarget(object):
    name: str
    type: SwiftTargetType

    def __init__(self, obj: Any):
        self.name = obj['name']
        self.type = SwiftTargetType(obj['type'])


T = TypeVar("T")


def deserialize_json(target_class: Callable[[Any], T], object_repr: str | bytes | bytearray) -> T:
    data = json.loads(object_repr)
    signature = inspect.signature(target_class)
    bound_signature = signature.bind(**data)
    bound_signature.apply_defaults()
    return target_class(**bound_signature.arguments)


def run_output(bin_name: str, *args: str | PathLike, echo: bool = True) -> bytes:
    if echo:
        print('>', bin_name, *list(args))

    return subprocess.check_output([bin_name] + list(args))


def run(bin_name: str, *args: str | PathLike, echo: bool = True, silent: bool = False):
    if echo:
        print('>', bin_name, *list(args))

    if silent:
        subprocess.check_output([bin_name] + list(args))
    else:
        subprocess.check_call([bin_name] + list(args))


def find(predicate: Callable[[T], bool], list: List[T]) -> Optional[T]:
    for item in list:
        if predicate(item):
            return item

    return None


def find_index(predicate: Callable[[T], bool], list: List[T]) -> Optional[int]:
    for (i, item) in enumerate(list):
        if predicate(item):
            return i

    return None


def get_package_description() -> Any:
    j = run_output('swift', 'package', 'dump-package')

    return json.loads(j)


def default_manifest_path(target_name: str) -> Path:
    return Path.cwd().joinpath('Sources').joinpath(target_name).joinpath(f'{target_name}.exe.manifest')


def run_post_build(settings: PostBuildSettings):
    run('mt', '-nologo', '-manifest', settings.manifest_path, f'-outputresource:{settings.exe_path}')

def run_manifest_patch(build_dir: Path, target_name: str, manifest_path: str):
    exe_path = build_dir.joinpath(target_name).with_suffix('.exe')

    manifest_path = manifest_path
    if manifest_path is None:
        manifest_path = default_manifest_path(target_name)

    run_post_build(PostBuildSettings(exe_path, manifest_path))

def run_build(settings: BuildCommandArgs):
    run('swift', '--version', silent=False)

    package = get_package_description()

    args = settings.swift_build_args()

    run('swift', 'build', *args)

    if settings.target_name is None:
        return

    target_json = find(lambda target: target['name'] == settings.target_name, package['targets'])
    if target_json is None:
        raise Exception(f"Target '{settings.target_name}' is not defined in Package.swift.")

    target = SwiftTarget(target_json)

    if target.type == SwiftTargetType.EXECUTABLE:
        build_dir = Path(run_output('swift', 'build', "--show-bin-path", *args).decode('UTF8').strip())

        manifest_path = settings.manifest_path
        if manifest_path is None:
            manifest_path = default_manifest_path(target.name)

        run_manifest_patch(build_dir, target.name, manifest_path)

    return

def run_test(settings: TestCommandArgs):
    args = settings.swift_test_args()
    run('swift', 'test', *args)

    return


def run_target(settings: RunCommandArgs):
    args = settings.swift_build_args()

    run('swift', 'build', *args)

    if settings.target_name is not None:
        build_dir = Path(run_output('swift', 'build', "--show-bin-path", *args).decode('UTF8').strip())

        manifest_path = settings.manifest_path
        if manifest_path is None:
            manifest_path = default_manifest_path(settings.target_name)

        run_manifest_patch(build_dir, settings.target_name, manifest_path)

    run('swift', 'run', '--skip-build', *settings.swift_run_args())

    return


def do_build_command(args: Any):
    settings = BuildCommandArgs(args.target, args.configuration, args.manifest_path, args.definitions)
    run_build(settings)

    print('Success!')

    return


def do_test_command(args: Any):
    settings = TestCommandArgs(args.configuration, args.definitions)
    run_test(settings)

    print('Success!')

    return


def do_run_command(args: Any):
    settings = RunCommandArgs(args.target, args.executable, args.configuration, args.manifest_path, args.definitions)
    run_target(settings)
    return


def main() -> int:
    argparser = make_argparser()
    args = argparser.parse_args()

    match args.command:
        case 'build':
            do_build_command(args)
        case 'test':
            do_test_command(args)
        case 'run':
            do_run_command(args)

    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except subprocess.CalledProcessError as err:
        sys.exit(err.returncode)
    except KeyboardInterrupt:
        sys.exit(1)
