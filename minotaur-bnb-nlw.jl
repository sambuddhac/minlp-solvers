#!/usr/bin/env julia

using ArgParse

using JuMP
using AmplNLWriter

include("common.jl")

function main(parsed_args) 
    include(parsed_args["file"])
    # this adds a model named m to the current scope

    optoins = String[]
    append!(optoins, ["--obj_gap_percent"])
    append!(optoins, ["1e-2"])

    # seems to break things
    #append!(optoins, ["--fpump"])
    #append!(optoins, ["1"])

    #append!(optoins, ["--msbnb_restarts"])
    #append!(optoins, ["0"])

    if parsed_args["ipopt"]
        append!(optoins, ["--nlp_engine"])
        append!(optoins, ["IPOPT"])
    end

    if parsed_args["time-limit"] != nothing
        tl = parsed_args["time-limit"]
        append!(optoins, ["--bnb_time_limit"])
        append!(optoins, ["$(tl)"])
    end

    if parsed_args["print-level"] != nothing
        pl = parsed_args["print-level"]
        append!(optoins, ["--log_level"])
        append!(optoins, ["$(pl)"])
    end

    solver = AmplNLSolver("bnb", optoins)

    setsolver(m, solver)

    status = solve(m)

    print_result(m, status, parsed_args["file"])
end

function parse_commandline_minotaur()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--file", "-f"
            help = "the minlplib data file (.jl)"
            required = true
        "--time-limit", "-t"
            help = "puts a time limit on the sovler"
            arg_type = Float64
        "--print-level", "-o"
            help = "controls terminal output verbosity"
            arg_type = Int64
        "--ipopt", "-i"
            help = "use ipopt for the nlp engine"
            action = :store_true
    end

    return parse_args(s)
end

if isinteractive() == false
  main(parse_commandline_minotaur())
end

