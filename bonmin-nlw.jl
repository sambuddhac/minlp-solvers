#!/usr/bin/env julia

using ArgParse

using JuMP
using AmplNLWriter

include("common.jl")

function main(parsed_args) 
    include(parsed_args["file"])
    # this adds a model named m to the current scope

    optoins = String[]
    append!(optoins, ["bonmin.allowable_fraction_gap=1e-4"])
    append!(optoins, ["bonmin.num_resolve_at_root=3"])

    if parsed_args["time-limit"] != nothing
        tl = parsed_args["time-limit"]
        append!(optoins, ["bonmin.time_limit=$(tl)"])
    end

    if parsed_args["print-level"] != nothing
        pl = parsed_args["print-level"]
        append!(optoins, ["print_level=$(pl)"])
    end

    solver = AmplNLSolver("bonmin", optoins)

    setsolver(m, solver)

    status = solve(m)

    print_result(m, status, parsed_args["file"])
end

if isinteractive() == false
  main(parse_commandline())
end
