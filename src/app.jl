# Julia login API using HTTP.jl, CSV.jl, and DataFrames.jl
# File: login_api.jl

using HTTP
using JSON
using CSV
using DataFrames

const USERS_CSV = "users.csv"

function init_users_csv()
    if !isfile(USERS_CSV)
        sample = DataFrame(user=["alice", "bob", "carol"],
                           password=["pass123", "secret", "qwerty"] )
        CSV.write(USERS_CSV, sample)
        println("Created sample users.csv")
    end
end

function load_users()::Dict{String,String}
    df = CSV.read(USERS_CSV, DataFrame)
    return Dict(row.user => row.password for row in eachrow(df))
end

function add_user(user::String, password::String)
    open(USERS_CSV, "a") do io
        println(io, "$user;$password;")
    end
end

function login_handler(req::HTTP.Request)
    raw = String(req.body)
    @info "Payload recebido" raw

    data = try
        JSON.parse(raw)
    catch err
        return HTTP.Response(400, "Invalid JSON")
    end

    user = get(data, "user", nothing)
    pwd  = get(data, "password", nothing)
    if user === nothing || pwd === nothing
        return HTTP.Response(400, "Missing 'user' or 'password'")
    end

    users = load_users()
    if haskey(users, user)
        return HTTP.Response(200, users[user] == pwd ? "OK" : "INCORRECT")
    else
        add_user(user, pwd)
        return HTTP.Response(200, "OK")
    end
end

function main()
    init_users_csv()
    println("Starting server on http://127.0.0.1:8080...")
    HTTP.serve(request -> begin
        if request.method == "POST" && request.target == "/login"
            return login_handler(request)
        else
            return HTTP.Response(404, "Not Found")
        end
    end, "127.0.0.1", 8080)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
