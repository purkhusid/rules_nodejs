"Convenience for testing that an output matches a file"

load("@build_bazel_rules_nodejs//internal/node:node.bzl", "nodejs_binary", "nodejs_test")

def generated_file_test(name, generated, src, src_dbg = None, **kwargs):
    """Tests that a file generated by Bazel has identical content to a file in the workspace.

    This is useful for testing, where a "snapshot" or "golden" file is checked in,
    so that you can code review changes to the generated output.

    Args:
        name: Name of the rule.
        generated: a Label of the output file generated by another rule
        src: Label of the source file in the workspace
        src_dbg: if the build uses `--compilation_mode dbg` then some rules will produce different output.
            In this case you can specify what the dbg version of the output should look like
        **kwargs: extra arguments passed to the underlying nodejs_test or nodejs_binary
    """
    data = [src, generated]

    if src_dbg:
        data.append(src_dbg)
    else:
        src_dbg = src

    loc = "$(rootpath %s)"
    nodejs_test(
        name = name,
        entry_point = "@build_bazel_rules_nodejs//internal/generated_file_test:bundle.js",
        templated_args = ["--verify", loc % src, loc % src_dbg, loc % generated],
        data = data,
        **kwargs
    )

    nodejs_binary(
        name = name + ".update",
        testonly = True,
        entry_point = "@build_bazel_rules_nodejs//internal/generated_file_test:bundle.js",
        templated_args = ["--out", loc % src, loc % src_dbg, loc % generated],
        data = data,
        **kwargs
    )
