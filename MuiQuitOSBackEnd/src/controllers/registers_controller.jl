using CSV
using DataFrames
using JSON3
using HTTP
using Dates

const PROJECT_ROOT = normpath(joinpath(@__DIR__, "..", "..", ".."))
const REGISTERS_CSV = joinpath(PROJECT_ROOT, "database", "registers.csv")
const USERS_CSV = joinpath(PROJECT_ROOT, "database", "users.csv")

function read_registers()
    df = CSV.read(REGISTERS_CSV, DataFrame; dateformat="yyyy-mm-ddTHH:MM:SS", types=Dict(:intensity=>Float64, :latitude=>Float64, :longitude=>Float64))
    return [Register(row.register_id, row.user_id, row.cep, DateTime(row.datetime), row.intensity, ismissing(row.evidence) ? nothing : row.evidence, row.latitude, row.longitude, row.city, row.state, row.neighbourhood, row.access_difficulty, row.focus_size, row.larvae) for row in eachrow(df)]
end

function write_registers(registers)
    df = DataFrame(register_id = [r.register_id for r in registers],
                    user_id = [r.user_id for r in registers],
                    cep = [r.cep for r in registers],
                    datetime = [Dates.format(r.datetime, "yyyy-mm-ddTHH:MM:SS") for r in registers],
                    intensity = [r.intensity for r in registers],
                    evidence = [r.evidence === nothing ? "" : r.evidence for r in registers],
                    latitude = [r.latitude for r in registers],
                    longitude = [r.longitude for r in registers],
                    city = [r.city for r in registers],
                    state = [r.state for r in registers],
                    neighbourhood = [r.neighbourhood for r in registers],
                    access_difficulty = [r.access_difficulty for r in registers],
                    focus_size = [r.focus_size for r in registers],
                    larvae = [r.larvae for r in registers])
    CSV.write(REGISTERS_CSV, df)
end

function user_exists(user_id)
    df = CSV.read(USERS_CSV, DataFrame)
    return any(row -> row.email == user_id, eachrow(df))
end

function handle_registers(req)
    if req.method == "GET"
        registers = read_registers()
        return HTTP.Response(200, JSON3.write(registers))
    elseif req.method == "POST"
        data = JSON3.read(String(req.body))
        if !user_exists(data["user_id"])
            return HTTP.Response(400, "Usuário não encontrado para user_id informado")
        end
        registers = read_registers()
        new_register_id = isempty(registers) ? 1 : maximum([r.register_id for r in registers]) + 1
        push!(registers, Register(new_register_id, data["user_id"], data["cep"], DateTime(data["datetime"]), Float64(data["intensity"]), get(data, "evidence", nothing), Float64(data["latitude"]), Float64(data["longitude"]), data["city"], data["state"], data["neighbourhood"], Int(data["access_difficulty"]), Int(data["focus_size"]), Bool(data["larvae"])))
        write_registers(registers)
        return HTTP.Response(201, "Register created")
    elseif req.method == "PUT"
        data = JSON3.read(String(req.body))
        registers = read_registers()
        for r in registers
            if r.register_id == data["register_id"]
                r.user_id = data["user_id"]
                r.cep = data["cep"]
                r.datetime = DateTime(data["datetime"])
                r.intensity = Float64(data["intensity"])
                r.evidence = get(data, "evidence", nothing)
                r.latitude = Float64(data["latitude"])
                r.longitude = Float64(data["longitude"])
                r.city = data["city"]
                r.state = data["state"]
                r.neighbourhood = data["neighbourhood"]
                r.access_difficulty = Int(data["access_difficulty"])
                r.focus_size = Int(data["focus_size"])
                r.larvae = Bool(data["larvae"])
            end
        end
        write_registers(registers)
        return HTTP.Response(200, "Register updated")
    elseif req.method == "DELETE"
        data = JSON3.read(String(req.body))
        registers = read_registers()
        registers = filter(r -> r.register_id != data["register_id"], registers)
        write_registers(registers)
        return HTTP.Response(200, "Register deleted")
    end
    return HTTP.Response(405, "Method Not Allowed")
end
