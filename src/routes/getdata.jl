module DataRoute

using HTTP
using CSV
using DataFrames
using JSON

const DATA_CSV = joinpath(@__DIR__, "..", "..", "database", "data.csv")

function init_data_csv()
    dir = dirname(DATA_CSV)
    if !isdir(dir)
        mkpath(dir)
    end

    if !isfile(DATA_CSV)
        sample = DataFrame(
            user=String[],
            cep=String[],
            intensity=Int[],
            date=String[]  # ou Date[], se estiver usando Dates
        )
        CSV.write(DATA_CSV, sample)
        println("Created sample data.csv")
    end
end

function data_handler(req::HTTP.Request)
    df = CSV.read(DATA_CSV, DataFrame)
    return HTTP.Response(200, JSON.json(df))
end

export init_data_csv, data_handler

end 
