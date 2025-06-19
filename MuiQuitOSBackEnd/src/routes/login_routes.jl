function login_routes(req)
    if req.target == "/login" && req.method == "POST"
        return handle_login(req)
    end
    return nothing
end
