
include("../routes/login.jl")

using HTTP
using Logging
using .LoginRoute


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
