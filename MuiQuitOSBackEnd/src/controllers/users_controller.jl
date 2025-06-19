using CSV
using DataFrames
using JSON3
using HTTP
using ..MuiQuitOSBackEnd: User

const PROJECT_ROOT = normpath(joinpath(@__DIR__, "..", "..", ".."))
const USERS_CSV = joinpath(PROJECT_ROOT, "database", "users.csv")

function read_users()
    df = CSV.read(USERS_CSV, DataFrame)
    return [User(row.name, row.email, row.password, row.type) for row in eachrow(df)]
end

function write_users(users)
    df = DataFrame(name = [u.name for u in users],
                    email = [u.email for u in users],
                    password = [u.password for u in users],
                    type = [u.type for u in users])
    CSV.write(USERS_CSV, df)
end

function handle_users(req)
    if req.method == "GET"
        users = read_users()
        return HTTP.Response(200, JSON3.write(users))
    elseif req.method == "POST"
        data = JSON3.read(String(req.body))
        users = read_users()
        for u in users
            if u.email == data["email"]
                return HTTP.Response(409, "Email já cadastrado")
            end
        end
        push!(users, User(data["name"], data["email"], data["password"], data["type"]))
        write_users(users)
        return HTTP.Response(201, "User created")
    elseif req.method == "PUT"
        data = JSON3.read(String(req.body))
        users = read_users()
        for u in users
            if u.email == data["email"]
                u.name = data["name"]
                u.password = data["password"]
                u.type = data["type"]
            end
        end
        write_users(users)
        return HTTP.Response(200, "User updated")
    elseif req.method == "DELETE"
        data = JSON3.read(String(req.body))
        users = read_users()
        users = filter(u -> u.email != data["email"], users)
        write_users(users)
        return HTTP.Response(200, "User deleted")
    end
    return HTTP.Response(405, "Method Not Allowed")
end
