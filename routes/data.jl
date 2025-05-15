module DataRoute

using HTTP
using JSON
using CSV
using DataFrames
using Dates

const DATA_CSV = "mosquito_data.csv"

"""
    init_data_csv()

Se o arquivo CSV não existir, cria um com cabeçalho
baseado nos campos esperados.
"""
function init_data_csv()
    if !isfile(DATA_CSV)
        df = DataFrame(
            id       = String[],
            latitude = Float64[],
            longitude= Float64[],
            timestamp= String[],
            area     = String[]
        )
        CSV.write(DATA_CSV, df)
        println("✔ Created empty $(DATA_CSV)")
    end
end

"""
    data_handler(req::HTTP.Request)

Lê o corpo JSON, extrai os campos e faz append
no CSV. Retorna 200 ou 500 em caso de erro.
"""
function data_handler(req::HTTP.Request)
    # Aceita apenas método POST
    if req.method != "POST"
        return HTTP.Response(405, "Method Not Allowed")
    end

    try
        # Debug logs
        println(">>> DEBUG: Incoming request, method=", req.method, " target=", String(req.target))
        payload = String(req.body)
        println(">>> DEBUG: Payload body = ", payload)

        # Parse JSON
        obj = JSON.parse(payload)

        # Extrai campos
        id_val    = get(obj, "id", "")
        lat       = parse(Float64, string(get(obj, "latitude", 0.0)))
        lon       = parse(Float64, string(get(obj, "longitude", 0.0)))
        ts        = get(obj, "timestamp", Dates.format(now(), dateformat"yyyy-mm-ddTHH:MM:SS"))
        area_name = get(obj, "area", "")

        # Monta DataFrame de uma linha
        row = DataFrame(
            id        = [id_val],
            latitude  = [lat],
            longitude = [lon],
            timestamp = [ts],
            area      = [area_name]
        )

        # Append no CSV
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

export init_data_csv, data_handler

end # module
