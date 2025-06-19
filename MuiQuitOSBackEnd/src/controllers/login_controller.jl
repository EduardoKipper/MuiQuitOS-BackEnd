using CSV
using DataFrames
using JSON3
using HTTP

const PROJECT_ROOT = normpath(joinpath(@__DIR__, "..", "..", ".."))
const USERS_CSV = joinpath(PROJECT_ROOT, "database", "users.csv")

function read_users_for_login()
    df = CSV.read(USERS_CSV, DataFrame)
    return [User(row.name, row.email, row.password, row.type) for row in eachrow(df)]
end

function handle_login(req)
    data = JSON3.read(String(req.body))
    users = read_users_for_login()
    for u in users
        if u.name == data["name"] && u.password == data["password"]
            return HTTP.Response(200, JSON3.write(Dict("name"=>u.name, "email"=>u.email, "type"=>u.type)))
        end
    end
    return HTTP.Response(401, "Invalid credentials")
end
