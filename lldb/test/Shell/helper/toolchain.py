import os
import itertools
import platform
import re
import subprocess
import sys

import lit.util
from lit.formats import ShTest
from lit.llvm import llvm_config
from lit.llvm.subst import FindTool
from lit.llvm.subst import ToolSubst

import posixpath

def _get_lldb_init_path(config):
    return os.path.join(config.test_exec_root, "lit-lldb-init-quiet")


def _disallow(config, execName):
    warning = """
    echo '*** Do not use \'{0}\' in tests; use \'%''{0}\'. ***' &&
    exit 1 && echo
  """
    config.substitutions.append((" {0} ".format(execName), warning.format(execName)))


def get_lldb_args(config, suffix=""):
    lldb_args = []
    if "remote-linux" in config.available_features:
        lldb_args += [
            "-O",
            '"platform select remote-linux"',
            "-O",
            f'"platform connect {config.lldb_platform_url}"',
        ]
        if config.lldb_platform_working_dir:
            dir = posixpath.join(f"{config.lldb_platform_working_dir}", "shell")
            if suffix:
                dir += posixpath.join(dir, f"{suffix}")
            lldb_args += [
                "-O",
                f'"platform shell mkdir -p {dir}"',
                "-O",
                f'"platform settings -w {dir}"',
            ]
    lldb_args += ["--no-lldbinit", "-S", _get_lldb_init_path(config)]
    return lldb_args


class ShTestLldb(ShTest):
    def __init__(
        self, execute_external=False, extra_substitutions=[], preamble_commands=[]
    ):
        super().__init__(execute_external, extra_substitutions, preamble_commands)

    def execute(self, test, litConfig):
        # Run each Shell test in a separate directory (on remote).

        # Find directory change command in %lldb substitution.
        for i, t in enumerate(test.config.substitutions):
            if re.match(t[0], "%lldb"):
                cmd = t[1]
                if '-O "platform settings -w ' in cmd:
                    # If command is present, it is added by get_lldb_args.
                    # Replace the path with the tests' path in suite.
                    # Example:
                    # bin/lldb
                    #   -O "platform shell mkdir -p /home/user/shell"
                    #   -O "platform settings -w /home/user/shell" ...
                    # =>
                    # bin/lldb
                    #   -O "platform shell mkdir -p /home/user/shell/SymbolFile/Breakpad/inline-record.test"
                    #   -O "platform settings -w /home/user/shell/SymbolFile/Breakpad/inline-record.test" ...
                    args_def = " ".join(get_lldb_args(test.config))
                    args_unique = " ".join(
                        get_lldb_args(
                            test.config,
                            posixpath.join(*test.path_in_suite),
                        )
                    )
                    test.config.substitutions[i] = (
                        t[0],
                        cmd.replace(args_def, args_unique),
                    )
                break
        return super().execute(test, litConfig)


def use_lldb_substitutions(config):
    # Set up substitutions for primary tools.  These tools must come from config.lldb_tools_dir
    # which is basically the build output directory.  We do not want to find these in path or
    # anywhere else, since they are specifically the programs which are actually being tested.

    dsname = "debugserver" if platform.system() in ["Darwin"] else "lldb-server"
    dsargs = [] if platform.system() in ["Darwin"] else ["gdbserver"]

    build_script = os.path.dirname(__file__)
    build_script = os.path.join(build_script, "build.py")
    build_script_args = [
        build_script,
        (
            "--compiler=clang" if config.enable_remote else "--compiler=any"
        ),  # Default to best compiler
        "--arch=" + str(config.lldb_bitness),
    ]
    if config.lldb_lit_tools_dir:
        build_script_args.append("--tools-dir={0}".format(config.lldb_lit_tools_dir))
    if config.lldb_tools_dir:
        build_script_args.append("--tools-dir={0}".format(config.lldb_tools_dir))
    if config.llvm_libs_dir:
        build_script_args.append("--libs-dir={0}".format(config.llvm_libs_dir))
    if config.objc_gnustep_dir:
        build_script_args.append(
            '--objc-gnustep-dir="{0}"'.format(config.objc_gnustep_dir)
        )
    if config.cmake_sysroot:
        build_script_args.append("--sysroot={0}".format(config.cmake_sysroot))

    lldb_init = _get_lldb_init_path(config)

    primary_tools = [
        ToolSubst(
            "%lldb",
            command=FindTool("lldb"),
            extra_args=get_lldb_args(config),
            unresolved="fatal",
        ),
        ToolSubst(
            "%lldb-init",
            command=FindTool("lldb"),
            extra_args=["-S", lldb_init],
            unresolved="fatal",
        ),
        ToolSubst(
            "%lldb-noinit",
            command=FindTool("lldb"),
            extra_args=["--no-lldbinit"],
            unresolved="fatal",
        ),
        ToolSubst(
            "%lldb-server",
            command=FindTool("lldb-server"),
            extra_args=[],
            unresolved="ignore",
        ),
        ToolSubst(
            "%debugserver",
            command=FindTool(dsname),
            extra_args=dsargs,
            unresolved="ignore",
        ),
        ToolSubst(
            "%platformserver",
            command=FindTool("lldb-server"),
            extra_args=["platform"],
            unresolved="ignore",
        ),
        ToolSubst(
            "%lldb-rpc-gen",
            command=FindTool("lldb-rpc-gen"),
            # We need the LLDB build directory root to pass into the tool, not the test build root.
            extra_args=[
                "-p " + config.lldb_build_directory + "/..",
                '--extra-arg="-resource-dir=' + config.clang_resource_dir + '"',
            ],
            unresolved="ignore",
        ),
        "lldb-test",
        "lldb-dap",
        ToolSubst(
            "%build", command="'" + sys.executable + "'", extra_args=build_script_args
        ),
    ]

    _disallow(config, "lldb")
    _disallow(config, "lldb-server")
    _disallow(config, "debugserver")
    _disallow(config, "platformserver")

    llvm_config.add_tool_substitutions(primary_tools, [config.lldb_tools_dir])


def _use_msvc_substitutions(config):
    # If running from a Visual Studio Command prompt (e.g. vcvars), this will
    # detect the include and lib paths, and find cl.exe and link.exe and create
    # substitutions for each of them that explicitly specify /I and /L paths
    cl = lit.util.which("cl")

    if not cl:
        return

    # Don't use lit.util.which() for link.exe: In `git bash`, it will pick
    # up /usr/bin/link (another name for ln).
    link = os.path.join(os.path.dirname(cl), "link.exe")

    cl = '"' + cl + '"'
    link = '"' + link + '"'
    includes = os.getenv("INCLUDE", "").split(";")
    libs = os.getenv("LIB", "").split(";")

    config.available_features.add("msvc")
    compiler_flags = ['"/I{}"'.format(x) for x in includes if os.path.exists(x)]
    linker_flags = ['"/LIBPATH:{}"'.format(x) for x in libs if os.path.exists(x)]

    tools = [
        ToolSubst("%msvc_cl", command=cl, extra_args=compiler_flags),
        ToolSubst("%msvc_link", command=link, extra_args=linker_flags),
    ]
    llvm_config.add_tool_substitutions(tools)
    return


def use_support_substitutions(config):
    # Set up substitutions for support tools.  These tools can be overridden at the CMake
    # level (by specifying -DLLDB_LIT_TOOLS_DIR), installed, or as a last resort, we can use
    # the just-built version.
    if config.enable_remote:
        host_flags = ["--target=" + config.target_triple]
    else:
        host_flags = ["--target=" + config.host_triple]
    if platform.system() in ["Darwin"]:
        try:
            out = subprocess.check_output(["xcrun", "--show-sdk-path"]).strip()
            res = 0
        except OSError:
            res = -1
        if res == 0 and out:
            sdk_path = lit.util.to_string(out)
            llvm_config.lit_config.note("using SDKROOT: %r" % sdk_path)
            host_flags += ["-isysroot", sdk_path]
    elif sys.platform != "win32":
        host_flags += ["-pthread"]

    if sys.platform.startswith("netbsd"):
        # needed e.g. to use freshly built libc++
        host_flags += [
            "-L" + config.llvm_libs_dir,
            "-Wl,-rpath," + config.llvm_libs_dir,
        ]

    # The clang module cache is used for building inferiors.
    host_flags += ["-fmodules-cache-path={}".format(config.clang_module_cache)]

    if config.cmake_sysroot:
        host_flags += ["--sysroot={}".format(config.cmake_sysroot)]

    if config.enable_remote and config.has_libcxx:
        host_flags += [
            "-L{}".format(config.libcxx_libs_dir),
            "-lc++",
        ]

    host_flags = " ".join(host_flags)
    config.substitutions.append(("%clang_host", "%clang " + host_flags))
    config.substitutions.append(("%clangxx_host", "%clangxx " + host_flags))
    config.substitutions.append(
        ("%clang_cl_host", "%clang_cl --target=" + config.host_triple)
    )

    additional_tool_dirs = []
    if config.lldb_lit_tools_dir:
        additional_tool_dirs.append(config.lldb_lit_tools_dir)

    llvm_config.use_clang(
        additional_flags=["--target=specify-a-target-or-use-a-_host-substitution"],
        additional_tool_dirs=additional_tool_dirs,
        required=True,
        use_installed=True,
    )

    if sys.platform == "win32":
        _use_msvc_substitutions(config)

    have_lld = llvm_config.use_lld(
        additional_tool_dirs=additional_tool_dirs, required=False, use_installed=True
    )
    if have_lld:
        config.available_features.add("lld")

    support_tools = [
        "yaml2obj",
        "obj2yaml",
        "llvm-dwp",
        "llvm-pdbutil",
        "llvm-mc",
        "llvm-readobj",
        "llvm-objdump",
        "llvm-objcopy",
        "lli",
    ]
    additional_tool_dirs += [config.lldb_tools_dir, config.llvm_tools_dir]
    llvm_config.add_tool_substitutions(support_tools, additional_tool_dirs)

    _disallow(config, "clang")
