name = "libjpeg"

using Pkg; Pkg.add("JpegTurbo_jll")

using JpegTurbo_jll
jllroot = dirname(dirname(JpegTurbo_jll.libjpeg_path))

using Clang
const LIB_INCLUDE = joinpath(jllroot, "include") |> normpath
const HEADERS = filter(x->endswith(x, ".h"), readdir(LIB_INCLUDE))
const LIB_HEADERS = [joinpath(LIB_INCLUDE, header) for header in HEADERS]

refdir = joinpath.(@__DIR__, "ref_headers")
!isdir(refdir) && mkdir(refdir)
refpaths = joinpath.(refdir, basename.(LIB_HEADERS))
@show refpaths
cp.(LIB_HEADERS, refpaths, follow_symlinks=true)

@show HEADERS

wc = init(; headers = LIB_HEADERS,
            output_file = joinpath(@__DIR__, "$(name)_api.jl"),
            common_file = joinpath(@__DIR__, "$(name)_common.jl"),
            clang_includes = vcat(LIB_INCLUDE, CLANG_INCLUDE),
            clang_args = ["-I", joinpath(LIB_INCLUDE, "..")],
            header_wrapped = (root, current)->root == current,
            header_library = x->name,
            clang_diagnostics = true,
            )

run(wc)
rm(joinpath(@__DIR__, "LibTemplate.jl"))

open(joinpath(@__DIR__, "$(name)_fixes.jl"), "w") do io
    write(io, "# manual fixes\n\n")
    # write(io, "JSAMPLE\n")
end