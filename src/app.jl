include("./routes/login.jl")
include("./routes/getdata.jl")

using HTTP
using Logging
using JSON
using .LoginRoute
using .DataRoute

function main()
    init_users_csv()
    init_data_csv()
    println("Starting server on http://127.0.0.1:8080...")

    HTTP.serve(request -> begin
        if request.method == "POST" && request.target == "/login"
            return login_handler(request)
        elseif request.method == "GET" && request.target == "/data"
            return data_handler(request)
        else
            return HTTP.Response(404, "Not Found")
        end
    end, "127.0.0.1", 8080)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
