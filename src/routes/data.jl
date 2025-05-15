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
            date=String[]
        )
        CSV.write(DATA_CSV, sample)
        println("Created sample data.csv")
    end
end

function get_data_handler(req::HTTP.Request)
    df = CSV.read(DATA_CSV, DataFrame)
    return HTTP.Response(200, JSON.json(df))
end

function post_data_handler(req::HTTP.Request)

    try
        payload = String(req.body)

        obj = JSON.parse(req.body)

        user_val = get(obj, "user", "")
        cep_val = get(obj, "cep", "")
        intensity_val = get(obj, "intensity", "")
        date_val = get(obj, "date", "")

        row = DataFrame(
            id = [user_val],
            cep = [cep_val],
            intensity = [intensity_val],
            date = [date_val],
        )

        CSV.write(DATA_CSV, row; append=true)
        println(">>> DEBUG: Wrote to CSV ", DATA_CSV)

        return HTTP.Response(200, "Data saved")
    catch e
        # Imprime exceção e stacktrace para debug
        println(">>> EXCEÇÃO NO data_handler: ", e)
        for (i, frame) in enumerate(catch_backtrace())
            println("  $i) ", frame)
        end
        return HTTP.Response(500, "Internal error: $(e)")
    end
end

export init_data_csv, get_data_handler, post_data_handler

end 
