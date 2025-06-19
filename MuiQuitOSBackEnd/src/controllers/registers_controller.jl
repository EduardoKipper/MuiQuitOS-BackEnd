using CSV
using DataFrames
using JSON3
using HTTP
using Dates

const PROJECT_ROOT = normpath(joinpath(@__DIR__, "..", "..", ".."))
const REGISTERS_CSV = joinpath(PROJECT_ROOT, "database", "registers.csv")
const USERS_CSV = joinpath(PROJECT_ROOT, "database", "users.csv")

function read_registers()
    df = CSV.read(REGISTERS_CSV, DataFrame; dateformat="yyyy-mm-ddTHH:MM:SS")
    return [Register(row.user_id, row.cep, DateTime(row.datetime), Int(row.intensity), ismissing(row.evidence) ? nothing : row.evidence) for row in eachrow(df)]
end

function write_registers(registers)
    df = DataFrame(user_id = [r.user_id for r in registers],
                    cep = [r.cep for r in registers],
                    datetime = [Dates.format(r.datetime, "yyyy-mm-ddTHH:MM:SS") for r in registers],
                    intensity = [r.intensity for r in registers],
                    evidence = [r.evidence === nothing ? "" : r.evidence for r in registers])
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
        push!(registers, Register(data["user_id"], data["cep"], data["datetime"], Int(data["intensity"]), data["evidence"]))
        write_registers(registers)
        return HTTP.Response(201, "Register created")
    elseif req.method == "PUT"
        data = JSON3.read(String(req.body))
        registers = read_registers()
        for r in registers
            if r.user_id == data["user_id"] && r.cep == data["cep"] && r.datetime == data["datetime"]
                r.intensity = Int(data["intensity"])
                r.evidence = data["evidence"]
            end
        end
        write_registers(registers)
        return HTTP.Response(200, "Register updated")
    elseif req.method == "DELETE"
        data = JSON3.read(String(req.body))
        registers = read_registers()
        registers = filter(r -> !(r.user_id == data["user_id"] && r.cep == data["cep"] && r.datetime == data["datetime"]), registers)
        write_registers(registers)
        return HTTP.Response(200, "Register deleted")
    end
    return HTTP.Response(405, "Method Not Allowed")
end
